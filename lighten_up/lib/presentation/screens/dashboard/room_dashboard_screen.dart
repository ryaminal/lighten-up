import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lighten_up/core/constants/app_colors.dart';
import 'package:lighten_up/core/constants/app_text_styles.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/widgets/room_card.dart';
import 'package:lighten_up/core/widgets/notification_dock.dart';
import 'package:lighten_up/data/models/room.dart';
import 'package:lighten_up/presentation/providers/auth_provider.dart';

/// Main room dashboard screen (Light Board)
class RoomDashboardScreen extends ConsumerStatefulWidget {
  const RoomDashboardScreen({super.key});

  @override
  ConsumerState<RoomDashboardScreen> createState() =>
      _RoomDashboardScreenState();
}

class _RoomDashboardScreenState extends ConsumerState<RoomDashboardScreen> {
  String? selectedZone;
  final List<String> zones = [
    'All Zones',
    'Doctor\'s Wing',
    'Hygiene Wing',
    'Front Desk',
  ];

  // Mock room data - will be replaced with real data from API
  List<Room> get mockRooms => [
    Room(
      id: '1',
      name: 'Exam 1',
      status: RoomStatus.occupied,
      zone: 'Doctor\'s Wing',
      currentPatientName: 'J. Doe',
      lights: [
        RoomLight(
          id: '1',
          type: LightType.doctor,
          label: 'Doctor',
          status: LightStatus.active,
          priority: LightPriority.urgent,
          activatedByName: 'J. Doe',
          activatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        RoomLight(
          id: '2',
          type: LightType.assistant,
          label: 'Assistant',
          status: LightStatus.active,
          priority: LightPriority.normal,
          activatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        const RoomLight(
          id: '3',
          type: LightType.hygiene,
          label: 'Hygiene',
          status: LightStatus.inactive,
        ),
      ],
    ),
    const Room(
      id: '2',
      name: 'Exam 2',
      status: RoomStatus.available,
      zone: 'Doctor\'s Wing',
      lights: [
        RoomLight(
          id: '4',
          type: LightType.doctor,
          label: 'Doctor',
          status: LightStatus.inactive,
        ),
        RoomLight(
          id: '5',
          type: LightType.assistant,
          label: 'Assistant',
          status: LightStatus.inactive,
        ),
        RoomLight(
          id: '6',
          type: LightType.hygiene,
          label: 'Hygiene',
          status: LightStatus.inactive,
        ),
      ],
    ),
    Room(
      id: '3',
      name: 'Hygiene 1',
      status: RoomStatus.occupied,
      zone: 'Hygiene Wing',
      lights: [
        RoomLight(
          id: '7',
          type: LightType.hygiene,
          label: 'Ready',
          status: LightStatus.active,
          priority: LightPriority.normal,
          activatedAt: DateTime.now().subtract(const Duration(minutes: 8)),
        ),
      ],
    ),
    const Room(
      id: '4',
      name: 'Hygiene 2',
      status: RoomStatus.available,
      zone: 'Hygiene Wing',
      lights: [
        RoomLight(
          id: '8',
          type: LightType.hygiene,
          label: 'Ready',
          status: LightStatus.inactive,
        ),
      ],
    ),
    Room(
      id: '5',
      name: 'Front Desk',
      status: RoomStatus.occupied,
      zone: 'Front Desk',
      lights: [
        RoomLight(
          id: '9',
          type: LightType.assistant,
          label: 'Assistance',
          status: LightStatus.active,
          priority: LightPriority.urgent,
          activatedAt: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
      ],
    ),
  ];

  List<Room> get filteredRooms {
    if (selectedZone == null || selectedZone == 'All Zones') {
      return mockRooms;
    }
    return mockRooms.where((room) => room.zone == selectedZone).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final now = DateTime.now();
    final timeString =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Row(
      children: [
        Expanded(
          child: Scaffold(
            backgroundColor: const Color(0xFF0b1219),
            appBar: AppBar(
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
                  // Privacy toggle button
                  InkWell(
                    onTap: () {
                      // TODO: Toggle privacy mode
                    },
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusFull,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spaceSm,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility,
                            size: 18,
                            color: AppColors.alertGreen,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Privacy: Off',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              centerTitle: false,
              actions: [
                // Current time display (desktop)
                if (MediaQuery.of(context).size.width >= 600)
                  Center(
                    child: Text(
                      timeString,
                      style: AppTextStyles.headingLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                const SizedBox(width: AppDimensions.spaceMd),
                // User status button
                InkWell(
                  onTap: () {
                    // TODO: Show user menu
                  },
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceMd,
                      vertical: AppDimensions.spaceSm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
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
                ),
                const SizedBox(width: AppDimensions.spaceSm),
                // Notifications button
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      color: AppColors.textSecondary,
                      onPressed: () {
                        // TODO: Show notifications
                      },
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.alertRed,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF111a22),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppDimensions.spaceSm),
              ],
            ),
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  // Mobile clock header
                  if (MediaQuery.of(context).size.width < 600)
                    SliverToBoxAdapter(
                      child: Container(
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
                      ),
                    ),

                  // Zone filter chips
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.spaceMd),
                      child: Wrap(
                        spacing: AppDimensions.spaceSm,
                        runSpacing: AppDimensions.spaceSm,
                        children: zones.map((zone) {
                          final isSelected =
                              selectedZone == zone ||
                              (selectedZone == null && zone == 'All Zones');
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedZone = zone;
                              });
                            },
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMd,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.spaceMd,
                                vertical: AppDimensions.spaceSm,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.surfaceDark,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMd,
                                ),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                ),
                              ),
                              child: Text(
                                zone,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Room grid
                  SliverPadding(
                    padding: const EdgeInsets.all(AppDimensions.spaceMd),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 350,
                        mainAxisSpacing: AppDimensions.spaceMd,
                        crossAxisSpacing: AppDimensions.spaceMd,
                        mainAxisExtent: 220,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final room = filteredRooms[index];
                        return RoomCard(
                          room: room,
                          onTap: () {
                            // TODO: Navigate to room details
                          },
                          onLightTap: (light) {
                            // TODO: Handle light tap (activate/acknowledge)
                            _showLightDialog(context, room, light);
                          },
                        );
                      }, childCount: filteredRooms.length),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const NotificationDock(),
      ],
    );
  }

  void _showLightDialog(BuildContext context, Room room, RoomLight light) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          '${room.displayLabel} - ${light.label}',
          style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              light.isActive ? 'Light is ACTIVE' : 'Light is inactive',
              style: AppTextStyles.bodyMedium.copyWith(
                color: light.isActive
                    ? AppColors.alertGreen
                    : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (light.isActive) ...[
              const SizedBox(height: AppDimensions.spaceSm),
              Text(
                'Active for: ${light.timerDisplay}',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
              if (light.activatedByName != null) ...[
                const SizedBox(height: AppDimensions.spaceSm),
                Text(
                  'Activated by: ${light.activatedByName}',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ],
            ],
          ],
        ),
        actions: [
          if (!light.isActive)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Activate light
              },
              child: const Text('Activate'),
            ),
          if (light.isActive)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Acknowledge light
              },
              child: const Text('Acknowledge'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
