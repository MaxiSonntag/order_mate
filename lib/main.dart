import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:ordermate/menu/settings/cubits/input_columns_cubit.dart';
import 'package:ordermate/menu/settings/cubits/multiple_orders_cubit.dart';
import 'package:ordermate/order_overview/customer_order.dart';
import 'package:ordermate/order_overview/order_overview_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ordermate/calculator/calculator_screen.dart';
import 'package:ordermate/menu/menu_selection/menu_selection_cubit.dart';
import 'package:ordermate/menu/menus_cubit/menus_cubit.dart';
import 'package:ordermate/order/order_cubit.dart';
import 'package:ordermate/utils/hive_adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  HiveAdapters.registerAdapters();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getTemporaryDirectory(),
  );

  runApp(const OrderMate());
}

class OrderMate extends StatelessWidget {
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
              shape: MaterialStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ),
        home: Builder(builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => MultipleOrdersCubit(
                  context.read<OrderCubit>().state,
                )..publishState(),
              ),
              BlocProvider(
                create: (context) => InputColumnsCubit(),
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
        }),
      ),
    );
  }
}
