import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:ordermate/components/outlined_icon_button.dart';
import 'package:ordermate/menu/menus_cubit/menus_cubit.dart';
import 'package:ordermate/menu/models/menu.dart';
import 'package:ordermate/menu/models/product.dart';
import 'package:ordermate/components/dotted_divider.dart';
import 'package:ordermate/utils/extensions.dart';
import 'package:ordermate/utils/input_formatters.dart';
import 'package:ordermate/utils/validators.dart';
import 'package:uuid/uuid.dart';

class EditMenuScreen extends StatelessWidget {
  final Menu? menu;

  final _formKey = GlobalKey<FormState>();
  final _autovalidate = ValueNotifier(AutovalidateMode.disabled);

  late final _nameCtrl = TextEditingController(text: menu?.name);
  final _nameNode = FocusNode();

  late final ValueNotifier<List<Product>> _products = ValueNotifier(
    menu?.products ?? [],
  );

  EditMenuScreen({super.key, this.menu});

  bool get isEdit => menu != null;

  Future<void> _saveMenu(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      final navigator = Navigator.of(context);

      final uuid = this.menu?.uuid ?? const Uuid().v4();
      final name = _nameCtrl.text;
      final products = _products.value;

      final menu = Menu(uuid: uuid, name: name, products: products);

      await context.read<MenusCubit>().saveMenu(menu);
      navigator.pop();
    } else {
      _autovalidate.value = AutovalidateMode.always;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? menu!.name : context.translate.addProductList),
        actions: [
          IconButton(
            onPressed: () => _saveMenu(context),
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: ValueListenableBuilder<AutovalidateMode>(
        valueListenable: _autovalidate,
        builder: (context, autovalidate, child) {
          return Form(
            key: _formKey,
            autovalidateMode: autovalidate,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        label: Text(context.translate.name),
                      ),
                      focusNode: _nameNode,
                      controller: _nameCtrl,
                      maxLines: 1,
                      validator: (text) {
                        return Validators.textNotEmpty(context, text);
                      },
                    ),
                    const SizedBox(height: 12.0),
                    const Divider(),
                    Text(
                      context.translate.products,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8.0),
                    ProductsFormField(
                      initialValue: menu?.products,
                      autovalidateMode: autovalidate,
                      onSaved: (products) {
                        if (products != null) {
                          _products.value = products;
                        }
                      },
                      validator: (products) {
                        if (products == null || products.isEmpty) {
                          return context.translate.productRequired;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProductsFormField extends FormField<List<Product>> {
  ProductsFormField({
    super.key,
    super.onSaved,
    super.validator,
    super.initialValue = const [],
    super.autovalidateMode,
  }) : super(
         builder: (FormFieldState<List<Product>> state) {
           List<Product> sortedProducts = List<Product>.from(state.value ?? [])
             ..sort((p1, p2) => p1.sortingKey - p2.sortingKey);

           return Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               if (state.hasError)
                 Text(
                   state.errorText ?? state.context.translate.unknownError,
                   style: TextStyle(
                     color: Theme.of(state.context).colorScheme.error,
                   ),
                 ),
               for (final product in sortedProducts) ...[
                 ListTile(
                   contentPadding: EdgeInsets.zero,
                   leading: Container(
                     width: 25,
                     height: 25,
                     decoration: BoxDecoration(
                       color: product.color,
                       borderRadius: BorderRadius.circular(4),
                     ),
                   ),
                   title: Text(product.name),
                   subtitle: Text(product.unit),
                   trailing: Text(
                     '${product.price.toStringAsFixed(2)}€',
                     style: Theme.of(state.context).textTheme.bodyMedium,
                   ),
                   onTap: () => _openActionsSheet(
                     state,
                     product: product,
                     onDelete: () {
                       state.didChange([...state.value!]..remove(product));
                       state.save();
                     },
                   ),
                 ),
                 if (product.isSectionEnd) DottedDivider(color: Colors.grey),
               ],
               Row(
                 children: [
                   Expanded(
                     child: OutlinedIconButton(
                       icon: const Icon(Icons.add_outlined),
                       onPressed: () => _openEditProductBottomSheet(state),
                       child: Text(state.context.translate.addProduct),
                     ),
                   ),
                 ],
               ),
             ],
           );
         },
       );

  static Future<void> _openActionsSheet(
    FormFieldState<List<Product>> state, {
    required Product product,
    VoidCallback? onDelete,
  }) async {
    final ctx = state.context;
    final action = await showModalBottomSheet<MenuProductAction>(
      context: ctx,
      builder: (context) => const ActionsSheet(),
    );

    if (action != null) {
      switch (action) {
        case MenuProductAction.edit:
          {
            _openEditProductBottomSheet(state, product: product);
            break;
          }
        case MenuProductAction.delete:
          {
            final shouldDelete = await _openDeleteConfirmationDialog(
              state,
              product,
            );

            if (shouldDelete) {
              onDelete?.call();
            }
            break;
          }
      }
    }
  }

  static Future<void> _openEditProductBottomSheet(
    FormFieldState<List<Product>> state, {
    Product? product,
  }) async {
    final newProduct = await showModalBottomSheet<Product?>(
      context: state.context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: EditProductSheet(product: product),
        );
      },
    );

    if (newProduct != null) {
      if (product != null) {
        final oldProducts = [...state.value!];
        final oldProductIndex = oldProducts.indexOf(product);
        oldProducts[oldProductIndex] = newProduct;
        state.didChange(oldProducts);
      } else {
        final highestSortingKey =
            state.value?.map((e) => e.sortingKey).reduce(max) ?? 0;

        state.didChange([
          ...state.value ?? <Product>[],
          newProduct.copyWith(sortingKey: highestSortingKey + 1),
        ]);
      }
      state.save();
    }
  }

  static Future<bool> _openDeleteConfirmationDialog(
    FormFieldState<List<Product>> state,
    Product product,
  ) async {
    return await showDialog(
      context: state.context,
      builder: (_) => AlertDialog(
        title: Text(
          state.context.translate.deleteItem(
            '${product.name} (${product.unit})',
          ),
        ),
        content: Text(
          state.context.translate.deletionQuestion(
            '${product.name} (${product.unit})',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(state.context).pop(false),
            child: Text(state.context.translate.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(state.context).pop(true),
            child: Text(
              state.context.translate.delete,
              style: TextStyle(
                color: Theme.of(state.context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionsSheet extends StatelessWidget {
  const ActionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(context.translate.edit),
            onTap: () => Navigator.of(context).pop(MenuProductAction.edit),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(context.translate.delete),
            onTap: () => Navigator.of(context).pop(MenuProductAction.delete),
          ),
        ],
      ),
    );
  }
}

enum MenuProductAction { edit, delete }

class EditProductSheet extends StatefulWidget {
  final Product? product;

  const EditProductSheet({super.key, this.product});

  @override
  State<EditProductSheet> createState() => _EditProductSheetState();
}

class _EditProductSheetState extends State<EditProductSheet> {
  final _formKey = GlobalKey<FormState>();

  final _autovalidate = ValueNotifier<AutovalidateMode>(
    AutovalidateMode.disabled,
  );

  final _displayNameNode = FocusNode();
  final _priceNode = FocusNode();
  final _unitNode = FocusNode();

  late final TextEditingController _displayNameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _unitCtrl;
  late final ValueNotifier<Color> _currentColor;
  late final ValueNotifier<bool> _isSectionEnd;

  bool get isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    _displayNameCtrl = TextEditingController(text: widget.product?.name);
    _priceCtrl = TextEditingController(
      text: widget.product?.price.toStringAsFixed(2),
    );
    _unitCtrl = TextEditingController(text: widget.product?.unit);
    _currentColor = ValueNotifier(widget.product?.color ?? Colors.green);
    _isSectionEnd = ValueNotifier(widget.product?.isSectionEnd ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
            child: ValueListenableBuilder<AutovalidateMode>(
              valueListenable: _autovalidate,
              builder: (context, autovalidate, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit
                          ? context.translate.editProduct
                          : context.translate.addProduct,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12.0),
                    TextFormField(
                      decoration: InputDecoration(
                        label: Text(context.translate.name),
                      ),
                      focusNode: _displayNameNode,
                      controller: _displayNameCtrl,
                      onFieldSubmitted: (_) {
                        _unitNode.requestFocus();
                      },
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                      autovalidateMode: autovalidate,
                      validator: (text) {
                        return Validators.textNotEmpty(context, text);
                      },
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      decoration: InputDecoration(
                        label: Text(context.translate.unit),
                      ),
                      focusNode: _unitNode,
                      controller: _unitCtrl,
                      onFieldSubmitted: (_) {
                        _priceNode.requestFocus();
                      },
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                      autovalidateMode: autovalidate,
                      validator: (text) {
                        return Validators.textNotEmpty(context, text);
                      },
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      decoration: InputDecoration(
                        label: Text(context.translate.price),
                        suffixIcon: const Icon(Icons.euro),
                      ),
                      focusNode: _priceNode,
                      controller: _priceCtrl,
                      inputFormatters: [
                        SignedDecimalFormatter(),
                        TextInputFormatter.withFunction(
                          (oldValue, newValue) => newValue.copyWith(
                            text: newValue.text.replaceAll(',', '.'),
                          ),
                        ),
                      ],
                      keyboardType: TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      maxLines: 1,
                      autovalidateMode: autovalidate,
                      validator: (text) {
                        if (Validators.textNotEmpty(context, text) == null) {
                          if (num.tryParse(text!) == null) {
                            return context.translate.invalidPriceFormat;
                          }
                        } else {
                          return Validators.textNotEmpty(context, text);
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8.0),
                    ColorPickerFormField(
                      initialValue: _currentColor.value,
                      autovalidateMode: autovalidate,
                      onSaved: (color) {
                        if (color != null) {
                          _currentColor.value = color;
                        }
                      },
                    ),
                    const SizedBox(height: 8.0),
                    ValueListenableBuilder(
                      valueListenable: _isSectionEnd,
                      builder: (context, isSectionEnd, _) {
                        return SwitchListTile(
                          title: Text(
                            context.translate.insertDividerBelowTitle,
                          ),
                          subtitle: Text(
                            context.translate.insertDividerBelowDesc,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 0),
                          value: isSectionEnd,
                          onChanged: (isSectionEnd) =>
                              _isSectionEnd.value = isSectionEnd,
                        );
                      },
                    ),
                    const SizedBox(height: 12.0),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedIconButton(
                            icon: const Icon(Icons.save_outlined),
                            onPressed: () => _save(context),
                            child: Text(context.translate.save),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _save(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      late final Product newProduct;

      final name = _displayNameCtrl.text;
      final unit = _unitCtrl.text;
      final price = num.parse(_priceCtrl.text);
      final color = _currentColor.value;
      final isSectionEnd = _isSectionEnd.value;

      newProduct = Product(
        name: name,
        unit: unit,
        price: price,
        sortingKey: widget.product?.sortingKey ?? -1,
        hexColor: color.hexString,
        isSectionEnd: isSectionEnd,
      );
      Navigator.of(context).pop(newProduct);
    } else {
      _autovalidate.value = AutovalidateMode.always;
    }
  }
}

class ColorPickerFormField extends FormField<Color> {
  ColorPickerFormField({
    super.key,
    super.onSaved,
    super.validator,
    Color super.initialValue = Colors.black12,
    super.autovalidateMode,
  }) : super(
         builder: (FormFieldState<Color> state) {
           return Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text(state.context.translate.color),
               InkWell(
                 onTap: () async {
                   final color = await showDialog(
                     context: state.context,
                     builder: (context) => AlertDialog(
                       content: SingleChildScrollView(
                         child: ColorPicker(
                           pickerColor: state.value ?? initialValue,
                           onColorChanged: (color) {
                             state.didChange(color);
                             state.save();
                           },
                         ),
                       ),
                       actions: [
                         TextButton(
                           onPressed: () {
                             Navigator.pop(context);
                           },
                           child: Text(context.translate.done),
                         ),
                       ],
                     ),
                   );
                   if (color != null) {
                     state.didChange(color);
                     state.save();
                   }
                 },
                 child: Container(
                   width: 100,
                   height: 35,
                   decoration: BoxDecoration(
                     color: state.value,
                     borderRadius: BorderRadius.circular(12.0),
                   ),
                 ),
               ),
             ],
           );
         },
       );
}
