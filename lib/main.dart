import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:ordermate/hive/hive_registrar.g.dart';
import 'package:ordermate/menu/menu_import_export/menu_import_cubit.dart';
import 'package:ordermate/menu/menu_selection/menu_selection_screen.dart';
import 'package:ordermate/menu/settings/cubits/input_columns_cubit.dart';
import 'package:ordermate/menu/settings/cubits/multiple_orders_cubit.dart';
import 'package:ordermate/order_overview/customer_order.dart';
import 'package:ordermate/order_overview/order_overview_screen.dart';
import 'package:ordermate/utils/extensions.dart';
import 'package:path_provider/path_provider.dart';
import 'l10n/app_localizations.dart';
import 'package:ordermate/calculator/calculator_screen.dart';
import 'package:ordermate/menu/menu_selection/menu_selection_cubit.dart';
import 'package:ordermate/menu/menus_cubit/menus_cubit.dart';
import 'package:ordermate/order/order_cubit.dart';

import 'menu/menu_import_export/file_ingress.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapters();

  FileIngress.init();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory:
        HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  runApp(const OrderMate());
}

class OrderMate extends StatelessWidget with WidgetsBindingObserver {
  const OrderMate({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MenusCubit()..loadMenus(),
        ),
        BlocProvider(
          create: (context) => MenuSelectionCubit(),
        ),
        BlocProvider(
          create: (context) => OrderCubit(),
        ),
        BlocProvider(
          create: (context) => InputColumnsCubit(),
        ),
        BlocProvider(
          create: (context) => MenuImportCubit(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData.from(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 139, 191, 66),
          ),
        ).copyWith(
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(8),
              ),
            ),
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            showDragHandle: true,
          ),
          outlinedButtonTheme: const OutlinedButtonThemeData(
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ),
        home: const OrderMateApp(),
      ),
    );
  }
}

class OrderMateApp extends StatefulWidget {
  const OrderMateApp({super.key});

  @override
  State<OrderMateApp> createState() => _OrderMateAppState();
}

class _OrderMateAppState extends State<OrderMateApp>
    with WidgetsBindingObserver {
  final StreamController<List<String>> _filesStream = StreamController();
  late final StreamSubscription<List<String>>? _filesStreamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final initialFiles = await FileIngress.getInitialFilesWithRetry();
      if (initialFiles.isNotEmpty) {
        _handleFiles(initialFiles);
      }
    });

    _filesStreamSubscription = FileIngress.stream().listen(_handleFiles);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      FileIngress.refreshOnResumed(); // non-blocking
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _filesStreamSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MultipleOrdersCubit(
            context.read<OrderCubit>().state,
          )..publishState(),
        ),
      ],
      child: Builder(builder: (context) {
        // Set initial settings state
        context.read<OrderCubit>().setMultipleOrdersAllowed(
              context.read<MultipleOrdersCubit>().state,
            );

        return BlocListener<OrderCubit, List<CustomerOrder>>(
          listener: (context, order) {
            context.read<MultipleOrdersCubit>().setCurrentOrder(order);
          },
          child: BlocConsumer<MultipleOrdersCubit, bool>(
            listener: (context, multipleOrdersAllowed) {
              context
                  .read<OrderCubit>()
                  .setMultipleOrdersAllowed(multipleOrdersAllowed);
            },
            builder: (context, multipleOrdersAllowed) {
              if (!multipleOrdersAllowed) {
                return CalculatorScreen();
              }

              return const OrderOverviewScreen();
            },
          ),
        );
      }),
    );
  }

  void _handleFiles(List<String> filePaths) {
    print('FILE PATHS: $filePaths');
    if (context.mounted) {
      context.read<MenuImportCubit>().importFile(filePaths.first);
      _openAddSheet(context);
    }
  }

/*  void getOpenFileUrl() async {
    String? url = await platform.invokeMethod('getOpenFileUrl');

    if (url != null) {
      if (url.isEmpty) {
        _showImportErrorSnackbar();
        return;
      }

      if (Platform.isAndroid) {
        final deviceInfo = await DeviceInfoPlugin().androidInfo;
        if (deviceInfo.version.sdkInt <= 32) {
          final storagePermission = await Permission.storage.request();
          if (storagePermission.isGranted && context.mounted) {
            context.read<MenuImportCubit>().importFile(url);
            _openAddSheet(context);
          } else if (context.mounted) {
            _showImportErrorSnackbar();
          }
          return;
        }
      }

      if (context.mounted) {
        context.read<MenuImportCubit>().importFile(url);
        _openAddSheet(context);
      }
    }
  }*/

  _showImportErrorSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.translate.importPermissionErrorMessage),
      ),
    );
  }

  void _openAddSheet(BuildContext context) async {
    final importCubit = context.read<MenuImportCubit>();

    await showModalBottomSheet(
      context: context,
      builder: (context) => const AddMenuSheet(),
    );

    importCubit.reset();
  }
}
