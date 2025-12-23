import 'package:flutter/material.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';
import 'package:lighten_up/core/utils/extensions.dart';

/// Large time display for mobile screens
class MobileTimeHeader extends StatelessWidget {
  final DateTime currentTime;

  const MobileTimeHeader({super.key, required this.currentTime});

  @override
  Widget build(BuildContext context) {
    final timeString = currentTime.to24HourString();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceLg),
      alignment: Alignment.center,
      child: Text(
        timeString,
        style: AppTextStyles.displayMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
