import 'package:flutter/material.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';
import 'package:lighten_up/data/models/user.dart';

/// Custom app bar for the dashboard with privacy toggle, time, user status, and notifications
class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final User? user;
  final DateTime currentTime;
  final bool isPrivacyMode;
  final VoidCallback onPrivacyToggle;
  final VoidCallback onUserStatusTap;
  final VoidCallback onNotificationsTap;
  final bool hasUnreadNotifications;

  const DashboardAppBar({
    super.key,
    this.user,
    required this.currentTime,
    this.isPrivacyMode = false,
    required this.onPrivacyToggle,
    required this.onUserStatusTap,
    required this.onNotificationsTap,
    this.hasUnreadNotifications = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final timeString =
        '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}';
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return AppBar(
      backgroundColor: const Color(0xFF111a22),
      elevation: 0,
      title: Row(
        children: [
          Text(
            'Office Communicator',
            style: AppTextStyles.headingSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceMd),
          Container(width: 1, height: 24, color: AppColors.borderDark),
          const SizedBox(width: AppDimensions.spaceMd),
          _buildPrivacyToggle(),
        ],
      ),
      centerTitle: false,
      actions: [
        if (isDesktop) _buildTimeDisplay(timeString),
        const SizedBox(width: AppDimensions.spaceMd),
        _buildUserStatusButton(),
        const SizedBox(width: AppDimensions.spaceSm),
        _buildNotificationButton(),
        const SizedBox(width: AppDimensions.spaceSm),
      ],
    );
  }

  Widget _buildPrivacyToggle() {
    return InkWell(
      onTap: onPrivacyToggle,
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceSm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPrivacyMode ? Icons.visibility_off : Icons.visibility,
              size: 18,
              color: isPrivacyMode ? AppColors.alertRed : AppColors.alertGreen,
            ),
            const SizedBox(width: 6),
            Text(
              'Privacy: ${isPrivacyMode ? 'On' : 'Off'}',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDisplay(String timeString) {
    return Center(
      child: Text(
        timeString,
        style: AppTextStyles.headingLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  Widget _buildUserStatusButton() {
    return InkWell(
      onTap: onUserStatusTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMd,
          vertical: AppDimensions.spaceSm,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppDimensions.spaceSm),
            Text(
              user?.fullName ?? 'User',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          color: AppColors.textSecondary,
          onPressed: onNotificationsTap,
        ),
        if (hasUnreadNotifications)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.alertRed,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF111a22), width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
