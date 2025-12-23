import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/widgets/room_card.dart';
import 'package:lighten_up/data/models/room.dart';
import 'package:lighten_up/presentation/providers/auth_provider.dart';
import 'package:lighten_up/presentation/screens/dashboard/widgets/dashboard_app_bar.dart';
import 'package:lighten_up/presentation/screens/dashboard/widgets/light_action_dialog.dart';
import 'package:lighten_up/presentation/screens/dashboard/widgets/mobile_time_header.dart';
import 'package:lighten_up/presentation/screens/dashboard/widgets/zone_filter_chips.dart';

/// Main room dashboard screen (Light Board) - Clean orchestrator
class RoomDashboardScreen extends ConsumerStatefulWidget {
  const RoomDashboardScreen({super.key});

  @override
  ConsumerState<RoomDashboardScreen> createState() =>
      _RoomDashboardScreenState();
}

class _RoomDashboardScreenState extends ConsumerState<RoomDashboardScreen> {
  String? selectedZone;
  bool isPrivacyMode = false;

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
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0b1219),
      appBar: DashboardAppBar(
        user: user,
        currentTime: now,
        isPrivacyMode: isPrivacyMode,
        onPrivacyToggle: () {
          setState(() {
            isPrivacyMode = !isPrivacyMode;
          });
        },
        onUserStatusTap: () {
          // TODO: Show user menu
        },
        onNotificationsTap: () {
          // TODO: Show notifications
        },
        hasUnreadNotifications: true,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Mobile clock header
            if (isMobile)
              SliverToBoxAdapter(child: MobileTimeHeader(currentTime: now)),

            // Zone filter chips
            SliverToBoxAdapter(
              child: ZoneFilterChips(
                zones: zones,
                selectedZone: selectedZone,
                onZoneSelected: (zone) {
                  setState(() {
                    selectedZone = zone;
                  });
                },
              ),
            ),

            // Room grid
            SliverPadding(
              padding: const EdgeInsets.all(AppDimensions.spaceMd),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
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
                      LightActionDialog.show(
                        context,
                        room,
                        light,
                        onActivate: () {
                          // TODO: Activate light
                        },
                        onAcknowledge: () {
                          // TODO: Acknowledge light
                        },
                      );
                    },
                  );
                }, childCount: filteredRooms.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
