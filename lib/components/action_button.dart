import 'package:flutter/material.dart';
import 'package:ordermate/utils/constants.dart';

class ActionButton extends StatefulWidget {
  final Color color;
  final Widget child;
  final VoidCallback? onPressed;
  final double? height;
  final bool useSafeArea;
  final EdgeInsetsGeometry? margin;

  const ActionButton({
    super.key,
    required this.color,
    required this.child,
    this.onPressed,
    this.height,
    this.useSafeArea = true,
    this.margin,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bottomPadding =
        widget.useSafeArea ? MediaQuery.of(context).padding.bottom : 0.0;

    final defaultMargin = EdgeInsets.only(
      left: AppConstants.spacingL,
      right: AppConstants.spacingL,
      bottom: bottomPadding + AppConstants.spacingS,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: AppConstants.animationFast,
        child: Container(
          margin: widget.margin ?? defaultMargin,
          height: widget.height ?? AppConstants.buttonHeightDefault,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
            color: widget.color.withValues(alpha: AppConstants.opacitySubtle),
            border: Border.all(
              color: widget.color.withValues(alpha: AppConstants.opacityMedium),
              width: AppConstants.borderWidth,
            ),
          ),
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: AppConstants.spacingXL),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class ActionButtonContent extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailingText;
  final Color color;
  final bool centered;

  const ActionButtonContent({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.trailingText,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: color,
          size: AppConstants.iconSizeL,
        ),
        const SizedBox(width: AppConstants.spacingM),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: color,
            letterSpacing: 0.3,
          ),
        ),
        if (!centered) const Spacer(),
        if (trailingText != null)
          Text(
            trailingText!,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: color,
            ),
          ),
      ],
    );
  }
}
