import 'package:flutter/material.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';

enum BadgeType {
  success,
  error,
  warning,
  info,
  neutral,
  urgent,
  high,
  medium,
  low,
}

enum BadgeSize { small, medium, large }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final BadgeSize size;
  final IconData? icon;
  final bool showDot;
  final Color? customColor;
  final Color? customTextColor;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = BadgeType.neutral,
    this.size = BadgeSize.medium,
    this.icon,
    this.showDot = false,
    this.customColor,
    this.customTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final dimensions = _getDimensions();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dimensions.horizontalPadding,
        vertical: dimensions.verticalPadding,
      ),
      decoration: BoxDecoration(
        color: customColor ?? colors.backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: colors.borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: dimensions.dotSize,
              height: dimensions.dotSize,
              decoration: BoxDecoration(
                color: customTextColor ?? colors.textColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: dimensions.spacing),
          ],
          if (icon != null) ...[
            Icon(
              icon,
              size: dimensions.iconSize,
              color: customTextColor ?? colors.textColor,
            ),
            SizedBox(width: dimensions.spacing),
          ],
          Text(
            label,
            style: dimensions.textStyle.copyWith(
              color: customTextColor ?? colors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeColors _getColors() {
    switch (type) {
      case BadgeType.success:
        return _BadgeColors(
          backgroundColor: AppColors.alertGreen.withValues(alpha: 0.1),
          borderColor: AppColors.alertGreen.withValues(alpha: 0.3),
          textColor: AppColors.alertGreen,
        );
      case BadgeType.error:
      case BadgeType.urgent:
        return _BadgeColors(
          backgroundColor: AppColors.alertRed.withValues(alpha: 0.1),
          borderColor: AppColors.alertRed.withValues(alpha: 0.3),
          textColor: AppColors.alertRed,
        );
      case BadgeType.warning:
      case BadgeType.high:
        return _BadgeColors(
          backgroundColor: AppColors.alertAmber.withValues(alpha: 0.1),
          borderColor: AppColors.alertAmber.withValues(alpha: 0.3),
          textColor: AppColors.alertAmber,
        );
      case BadgeType.info:
      case BadgeType.medium:
        return _BadgeColors(
          backgroundColor: AppColors.alertBlue.withValues(alpha: 0.1),
          borderColor: AppColors.alertBlue.withValues(alpha: 0.3),
          textColor: AppColors.alertBlue,
        );
      case BadgeType.low:
        return _BadgeColors(
          backgroundColor: AppColors.gray500.withValues(alpha: 0.1),
          borderColor: AppColors.gray500.withValues(alpha: 0.3),
          textColor: AppColors.gray400,
        );
      case BadgeType.neutral:
        return _BadgeColors(
          backgroundColor: AppColors.surfaceCard,
          borderColor: AppColors.borderDark,
          textColor: AppColors.textSecondary,
        );
    }
  }

  _BadgeDimensions _getDimensions() {
    switch (size) {
      case BadgeSize.small:
        return _BadgeDimensions(
          horizontalPadding: AppDimensions.spaceXs,
          verticalPadding: AppDimensions.space4xs,
          iconSize: AppDimensions.iconXs,
          dotSize: 6,
          spacing: AppDimensions.space3xs,
          textStyle: AppTextStyles.labelSmall,
        );
      case BadgeSize.medium:
        return _BadgeDimensions(
          horizontalPadding: AppDimensions.spaceSm,
          verticalPadding: AppDimensions.space3xs,
          iconSize: AppDimensions.iconSm,
          dotSize: 8,
          spacing: AppDimensions.space2xs,
          textStyle: AppTextStyles.labelMedium,
        );
      case BadgeSize.large:
        return _BadgeDimensions(
          horizontalPadding: AppDimensions.spaceMd,
          verticalPadding: AppDimensions.space2xs,
          iconSize: AppDimensions.iconMd,
          dotSize: 10,
          spacing: AppDimensions.spaceXs,
          textStyle: AppTextStyles.labelLarge,
        );
    }
  }
}

class _BadgeColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  _BadgeColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}

class _BadgeDimensions {
  final double horizontalPadding;
  final double verticalPadding;
  final double iconSize;
  final double dotSize;
  final double spacing;
  final TextStyle textStyle;

  _BadgeDimensions({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.iconSize,
    required this.dotSize,
    required this.spacing,
    required this.textStyle,
  });
}
