import 'package:flutter/material.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';

enum CardVariant { elevated, outlined, filled }

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final CardVariant variant;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final BorderRadius? borderRadius;
  final bool showShadow;
  final double? elevation;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.variant = CardVariant.elevated,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.showShadow = true,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding =
        padding ?? const EdgeInsets.all(AppDimensions.spaceMd);
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(AppDimensions.radiusMd);

    Widget cardContent = Container(
      padding: effectivePadding,
      decoration: _buildDecoration(context),
      child: child,
    );

    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: effectiveBorderRadius,
        child: cardContent,
      );
    }

    return cardContent;
  }

  BoxDecoration _buildDecoration(BuildContext context) {
    switch (variant) {
      case CardVariant.elevated:
        return BoxDecoration(
          color: backgroundColor ?? AppColors.surfaceCard,
          borderRadius:
              borderRadius ?? BorderRadius.circular(AppDimensions.radiusMd),
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: elevation ?? 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        );

      case CardVariant.outlined:
        return BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius:
              borderRadius ?? BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: borderColor ?? AppColors.borderDark,
            width: borderWidth ?? 1,
          ),
        );

      case CardVariant.filled:
        return BoxDecoration(
          color: backgroundColor ?? AppColors.surfaceDark,
          borderRadius:
              borderRadius ?? BorderRadius.circular(AppDimensions.radiusMd),
        );
    }
  }
}

class AppInfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  const AppInfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.icon,
    this.iconColor,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: padding ?? const EdgeInsets.all(AppDimensions.spaceMd),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: iconColor ?? AppColors.primary,
              size: AppDimensions.iconMd,
            ),
            const SizedBox(width: AppDimensions.spaceSm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: AppDimensions.spaceXs),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppDimensions.spaceSm),
            trailing!,
          ],
        ],
      ),
    );
  }
}
