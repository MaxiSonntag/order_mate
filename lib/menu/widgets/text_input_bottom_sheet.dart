import 'package:flutter/material.dart';
import 'package:ordermate/utils/extensions.dart';

class TextInputBottomSheet extends StatelessWidget {
  final String? title;
  final String? message;
  final String displayName;
  final Icon? icon;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _inputCtrl = TextEditingController();
  final FocusNode _inputNode = FocusNode();

  TextInputBottomSheet({
    super.key,
    this.title,
    this.message,
    required String currentValue,
    required this.displayName,
    this.icon,
  }) {
    _inputCtrl.text = currentValue;
  }

  _submitSetting(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(_inputCtrl.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) Text(title!),
              if (message != null) Text(message!),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Form(
                  key: _formKey,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _inputCtrl,
                          focusNode: _inputNode..requestFocus(),
                          decoration: InputDecoration(
                            label: Text(displayName),
                          ),
                          textInputAction: TextInputAction.done,
                          maxLines: 1,
                          onFieldSubmitted: (_) => _submitSetting(context),
                          validator: (val) {
                            if (val == null) {
                              return context.translate
                                  .requiredValidationErrorMessage(displayName);
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () => _submitSetting(context),
                        icon: icon ?? const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
