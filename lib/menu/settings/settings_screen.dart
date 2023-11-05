import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ordermate/menu/menu_selection/menu_selection_screen.dart';
import 'package:ordermate/menu/settings/cubits/input_columns_cubit.dart';
import 'package:ordermate/menu/settings/cubits/multiple_orders_cubit.dart';
import 'package:ordermate/menu/settings/settings_errors.dart';
import 'package:ordermate/utils/extensions.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MenuSelectionScreen(),
      ),
    );
  }

  void _showMultipleOrdersError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.translate.multipleOrdersError),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate.settings),
      ),
      body: ListView(
        children: [
          // Multiple orders
          BlocBuilder<MultipleOrdersCubit, bool>(
            builder: (context, multipleOrders) {
              return SwitchListTile(
                controlAffinity: ListTileControlAffinity.trailing,
                value: multipleOrders,
                onChanged: (_) {
                  try {
                    context.read<MultipleOrdersCubit>().toggleMultipleOrders();
                  } catch (e) {
                    if (e == multipleOrdersOpen) {
                      _showMultipleOrdersError(context);
                    }
                  }
                },
                title: Text(context.translate.multipleOrders),
                subtitle: Text(context.translate.multipleOrdersDesc),
              );
            },
          ),
          // Input column count
          BlocBuilder<InputColumnsCubit, int>(
            builder: (context, inputColumnCount) {
              final possibleInputColumns = _getPossibleInputColumns(context);
              if (possibleInputColumns.$1 == possibleInputColumns.$2) {
                return Container();
              }
              return ListTile(
                title: Text(context.translate.inputColumns),
                subtitle: Text(context.translate.inputColumnsDesc),
                trailing: DropdownButton<int>(
                  onChanged: (value) {
                    context.read<InputColumnsCubit>().setInputColumns(value!);
                  },
                  value: inputColumnCount,
                  items: [
                    for (int i = possibleInputColumns.$1;
                        i <= possibleInputColumns.$2;
                        i++)
                      DropdownMenuItem(
                        value: i,
                        child: Text('$i'),
                      ),
                  ],
                ),
              );
            },
          ),
          // Menu selection
          ListTile(
            title: Text(context.translate.productLists),
            subtitle: Text(context.translate.editProductListsDesc),
            trailing: const Icon(Icons.arrow_forward_ios_outlined),
            onTap: () => _navigateToSettings(context),
          ),
        ],
      ),
    );
  }

  (int, int) _getPossibleInputColumns(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    print(shortestSide);
    if (shortestSide <= 450) {
      // 14 Pro Max = 430
      return (2, 2);
    } else if (shortestSide <= 800) {
      // 10 inch Nexus = 800
      return (2, 3);
    } else {
      // 12.9 inch iPad = 1024
      return (2, 4);
    }
  }
}
