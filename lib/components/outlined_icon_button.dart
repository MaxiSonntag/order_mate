import 'package:flutter/material.dart';

class OutlinedIconButton extends StatelessWidget {
  final Icon icon;
  final VoidCallback onPressed;
  final Widget child;

  const OutlinedIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8.0),
          child,
        ],
      ),
    );
  }
}
