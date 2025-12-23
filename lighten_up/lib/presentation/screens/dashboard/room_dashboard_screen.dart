import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lighten_up/core/constants/app_dimensions.dart';
import 'package:lighten_up/core/widgets/room_card.dart';
import 'package:lighten_up/presentation/providers/auth_provider.dart';
import 'package:lighten_up/presentation/providers/room_provider.dart';
import 'package:lighten_up/presentation/screens/dashboard/widgets/dashboard_app_bar.dart';
import 'package:lighten_up/presentation/screens/dashboard/widgets/light_action_dialog.dart';
import 'package:lighten_up/presentation/screens/dashboard/widgets/mobile_time_header.dart';
import 'package:lighten_up/presentation/screens/dashboard/widgets/zone_filter_chips.dart';

/// Main room dashboard screen (Light Board) - Clean orchestrator
/// Refactored to follow Single Responsibility Principle - UI only
class RoomDashboardScreen extends ConsumerStatefulWidget {
  const RoomDashboardScreen({super.key});

  @override
  ConsumerState<RoomDashboardScreen> createState() =>
      _RoomDashboardScreenState();
}

class _RoomDashboardScreenState extends ConsumerState<RoomDashboardScreen> {
  bool isPrivacyMode = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final roomState = ref.watch(roomNotifierProvider);
    final roomNotifier = ref.read(roomNotifierProvider.notifier);

    final user = authState.user;
    final now = DateTime.now();
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Get data from provider instead of local state
    final zones = roomState.zones;
    final selectedZone = roomState.selectedZone;
    final filteredRooms = roomState.filteredRooms;

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
      body: roomState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : roomState.error != null
          ? Center(child: Text('Error: ${roomState.error}'))
          : SafeArea(
              child: CustomScrollView(
                slivers: [
                  // Mobile clock header
                  if (isMobile)
                    SliverToBoxAdapter(
                      child: MobileTimeHeader(currentTime: now),
                    ),

                  // Zone filter chips
                  SliverToBoxAdapter(
                    child: ZoneFilterChips(
                      zones: zones,
                      selectedZone: selectedZone,
                      onZoneSelected: (zone) {
                        roomNotifier.setSelectedZone(zone);
                      },
                    ),
                  ),

                  // Room grid
                  SliverPadding(
                    padding: const EdgeInsets.all(AppDimensions.spaceMd),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
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
                                roomNotifier.activateLight(room.id, light.id);
                              },
                              onAcknowledge: () {
                                roomNotifier.acknowledgeLight(
                                  room.id,
                                  light.id,
                                );
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
