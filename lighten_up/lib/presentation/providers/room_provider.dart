import 'package:flutter/foundation.dart';
import 'package:lighten_up/data/models/room.dart';
import 'package:lighten_up/presentation/providers/mock_room_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'room_provider.g.dart';

/// State for room management
class RoomState {
  final List<Room> rooms;
  final List<String> zones;
  final String? selectedZone;
  final bool isLoading;
  final String? error;

  const RoomState({
    this.rooms = const [],
    this.zones = const [],
    this.selectedZone,
    this.isLoading = false,
    this.error,
  });

  RoomState copyWith({
    List<Room>? rooms,
    List<String>? zones,
    String? selectedZone,
    bool? isLoading,
    String? error,
  }) {
    return RoomState(
      rooms: rooms ?? this.rooms,
      zones: zones ?? this.zones,
      selectedZone: selectedZone ?? this.selectedZone,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get filtered rooms based on selected zone
  List<Room> get filteredRooms {
    if (selectedZone == null || selectedZone == 'All Zones') {
      return rooms;
    }
    return rooms.where((room) => room.zone == selectedZone).toList();
  }
}

/// Provider for managing room data and filtering
@riverpod
class RoomNotifier extends _$RoomNotifier {
  @override
  RoomState build() {
    // Load mock data synchronously during initialization
    // This avoids async lifecycle issues with Riverpod's build() method
    // When connecting to real API, consider using AsyncNotifierProvider instead
    final rooms = MockRoomData.getRooms();
    final zones = MockRoomData.getZones();

    return RoomState(rooms: rooms, zones: zones, isLoading: false);
  }

  /// Load rooms from data source
  Future<void> _loadRooms() async {
    try {
      // Set loading state
      state = state.copyWith(isLoading: true, error: null);

      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 300));

      final rooms = MockRoomData.getRooms();
      final zones = MockRoomData.getZones();

      state = state.copyWith(rooms: rooms, zones: zones, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load rooms: ${e.toString()}',
      );
    }
  }

  /// Refresh rooms data
  Future<void> refreshRooms() async {
    await _loadRooms();
  }

  /// Set selected zone for filtering
  void setSelectedZone(String? zone) {
    state = state.copyWith(selectedZone: zone);
    debugPrint('Zone filter changed to: $zone');
  }

  /// Clear zone filter (show all rooms)
  void clearZoneFilter() {
    state = state.copyWith(selectedZone: 'All Zones');
  }

  /// Get rooms by zone
  List<Room> getRoomsByZone(String zone) {
    if (zone == 'All Zones') {
      return state.rooms;
    }
    return state.rooms.where((room) => room.zone == zone).toList();
  }

  /// Get active rooms (with active lights)
  List<Room> getActiveRooms() {
    return state.rooms.where((room) => room.hasActiveLights).toList();
  }

  /// Get urgent rooms (with urgent lights)
  List<Room> getUrgentRooms() {
    return state.rooms.where((room) => room.hasUrgentLights).toList();
  }

  /// Update a specific room
  void updateRoom(Room updatedRoom) {
    final updatedRooms = state.rooms.map((room) {
      return room.id == updatedRoom.id ? updatedRoom : room;
    }).toList();

    state = state.copyWith(rooms: updatedRooms);
  }

  /// Activate a light in a room
  Future<void> activateLight(String roomId, String lightId) async {
    // TODO: Call API to activate light
    debugPrint('Activating light $lightId in room $roomId');

    // Mock implementation - update local state
    final room = state.rooms.firstWhere((r) => r.id == roomId);
    final updatedLights = room.lights.map((light) {
      if (light.id == lightId) {
        return light.copyWith(
          status: LightStatus.active,
          activatedAt: DateTime.now(),
        );
      }
      return light;
    }).toList();

    final updatedRoom = room.copyWith(lights: updatedLights);
    updateRoom(updatedRoom);
  }

  /// Acknowledge a light in a room
  Future<void> acknowledgeLight(String roomId, String lightId) async {
    // TODO: Call API to acknowledge light
    debugPrint('Acknowledging light $lightId in room $roomId');

    // Mock implementation - update local state
    final room = state.rooms.firstWhere((r) => r.id == roomId);
    final updatedLights = room.lights.map((light) {
      if (light.id == lightId) {
        return light.copyWith(status: LightStatus.acknowledged);
      }
      return light;
    }).toList();

    final updatedRoom = room.copyWith(lights: updatedLights);
    updateRoom(updatedRoom);
  }
}
