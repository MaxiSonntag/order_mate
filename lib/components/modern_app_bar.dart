import 'package:flutter/material.dart';
import 'package:ordermate/utils/constants.dart';

class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<GlassIconButton>? actions;

  const ModernAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(AppConstants.appBarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppConstants.spacingS,
        left: showBackButton ? AppConstants.spacingM : AppConstants.spacingXL,
        right: AppConstants.spacingM,
        bottom: AppConstants.spacingS,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Row(
        children: [
          if (showBackButton) ...[
            GlassIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: AppConstants.spacingM),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (actions != null) ...[
            const SizedBox(width: AppConstants.spacingM),
            for (final action in actions!) ...[
              action,
              if (action != actions!.last)
                const SizedBox(width: AppConstants.spacingS),
            ],
          ],
        ],
      ),
    );
  }
}

class GlassIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const GlassIconButton({super.key, required this.icon, this.onTap});

  @override
  State<GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<GlassIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: AppConstants.animationFast,
        child: AnimatedOpacity(
          opacity: isEnabled ? 1.0 : AppConstants.opacityDisabled,
          duration: AppConstants.animationStandard,
          child: Container(
            width: AppConstants.glassButtonSize,
            height: AppConstants.glassButtonSize,
            decoration: BoxDecoration(
              color: ColorScheme.of(context)
                  .primary
                  .withValues(alpha: AppConstants.opacitySubtle),
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              boxShadow: [
                BoxShadow(
                  color: ColorScheme.of(context).primary.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              size: AppConstants.iconSizeM,
              color: ColorScheme.of(context).primary,
            ),
          ),
        ),
      ),
    );
  }
}
