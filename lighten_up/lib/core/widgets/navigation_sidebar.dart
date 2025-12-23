import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';
import 'package:lighten_up/presentation/providers/auth_provider.dart';

/// Navigation sidebar for desktop view
class NavigationSidebar extends ConsumerWidget {
  const NavigationSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouterState.of(context).uri.path;
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Material(
      color: const Color(0xFF111a22),
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: const Color(0xFF111a22),
          border: Border(
            right: BorderSide(color: AppColors.borderDark, width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with logo and clinic info
            Container(
              padding: const EdgeInsets.all(AppDimensions.spaceMd),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.borderDark, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusFull,
                      ),
                    ),
                    child: Icon(
                      Icons.local_hospital,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Main Clinic',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user?.department ?? 'North Wing System',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation menu
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppDimensions.spaceMd),
                children: [
                  Text(
                    'MENU',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: const Color(0xFF587593),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceSm),
                  _NavItem(
                    icon: Icons.grid_view,
                    label: 'Light Board',
                    route: '/',
                    isActive: currentRoute == '/',
                  ),
                  _NavItem(
                    icon: Icons.chat_bubble_outline,
                    label: 'Messages',
                    route: '/messages',
                    isActive: currentRoute == '/messages',
                    badge: 3,
                  ),
                  _NavItem(
                    icon: Icons.notifications_outlined,
                    label: 'Alerts',
                    route: '/alerts',
                    isActive: currentRoute == '/alerts',
                  ),
                  _NavItem(
                    icon: Icons.people_outline,
                    label: 'Staff List',
                    route: '/staff',
                    isActive: currentRoute == '/staff',
                  ),
                  _NavItem(
                    icon: Icons.analytics_outlined,
                    label: 'Reports',
                    route: '/reports',
                    isActive: currentRoute == '/reports',
                  ),
                ],
              ),
            ),

            // Footer with settings
            Container(
              padding: const EdgeInsets.all(AppDimensions.spaceMd),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.borderDark, width: 1),
                ),
              ),
              child: _NavItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                route: '/settings',
                isActive: currentRoute == '/settings',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Navigation item widget
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;
  final int? badge;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    this.isActive = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.space2xs),
      child: InkWell(
        onTap: () {
          context.go(route);
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceSm,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: AppDimensions.spaceSm),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isActive ? Colors.white : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.alertRed,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusFull,
                    ),
                  ),
                  child: Text(
                    badge.toString(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
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
