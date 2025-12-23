import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/widgets/app_button.dart';
import 'package:lighten_up/core/widgets/app_card.dart';
import 'package:lighten_up/presentation/providers/auth_provider.dart';

/// Main dashboard screen after login
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Lighten Up'),
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              AppCard(
                variant: CardVariant.elevated,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spaceLg),
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          user?.initials ?? '?',
                          style: AppTextStyles.headingMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spaceMd),
                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.space3xs),
                            Text(
                              user?.fullName ?? 'User',
                              style: AppTextStyles.headingMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.space3xs),
                            Text(
                              user?.roleDisplayName ?? 'Role',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spaceLg),

              // Quick Actions
              Text(
                'Quick Actions',
                style: AppTextStyles.headingSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceMd),

              // Action Cards Grid
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.message_outlined,
                      label: 'Messages',
                      color: AppColors.primary,
                      onTap: () {
                        // TODO: Navigate to messages
                      },
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceMd),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.warning_amber_outlined,
                      label: 'Alerts',
                      color: AppColors.alertRed,
                      onTap: () {
                        // TODO: Navigate to alerts
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.people_outline,
                      label: 'Patients',
                      color: AppColors.alertGreen,
                      onTap: () {
                        // TODO: Navigate to patients
                      },
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceMd),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.group_outlined,
                      label: 'Staff',
                      color: AppColors.alertAmber,
                      onTap: () {
                        // TODO: Navigate to staff
                      },
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Logout Button
              AppButton(
                label: 'Logout',
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                },
                type: AppButtonType.outline,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Action card widget for quick navigation
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: CardVariant.elevated,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceMd),
        child: Column(
          children: [
            Icon(icon, size: AppDimensions.iconXl, color: color),
            const SizedBox(height: AppDimensions.spaceSm),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
