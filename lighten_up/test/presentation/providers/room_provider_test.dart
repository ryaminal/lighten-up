import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighten_up/data/models/room.dart';
import 'package:lighten_up/presentation/providers/room_provider.dart';
import 'package:lighten_up/core/utils/logger.dart';
import 'package:logger/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('RoomProvider - Behavior Tests', () {
    late ProviderContainer container;

    setUp(() {
      // Set log level to only show errors during tests (clean output)
      AppLogger.setLevel(Level.error);

      // Create a new provider container for each test
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    /// Helper to wait for rooms to load by polling the state
    Future<void> waitForRoomsToLoad() async {
      // Trigger provider initialization
      container.read(roomNotifierProvider);

      // Poll until loading is complete (max 5 seconds)
      final stopwatch = Stopwatch()..start();
      while (container.read(roomNotifierProvider).isLoading) {
        if (stopwatch.elapsed.inSeconds > 5) {
          throw TimeoutException('Timeout waiting for rooms to load');
        }
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }

    group('Initialization', () {
      test('provider initializes with loaded data', () {
        // Act - Read the provider
        final state = container.read(roomNotifierProvider);

        // Assert - Data is loaded synchronously from mock data
        expect(state.rooms, isNotEmpty);
        expect(state.zones, isNotEmpty);
        expect(state.selectedZone, isNull);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('provider automatically loads rooms on initialization', () async {
        // Act - Wait for loading to complete
        await waitForRoomsToLoad();

        // Assert - Rooms and zones are loaded
        final state = container.read(roomNotifierProvider);
        expect(state.rooms, isNotEmpty);
        expect(state.zones, isNotEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('rooms are loaded from mock data', () async {
        // Act
        await waitForRoomsToLoad();

        // Assert - Mock data is loaded
        final state = container.read(roomNotifierProvider);
        expect(state.rooms.length, equals(5)); // MockRoomData has 5 rooms
        expect(
          state.zones.length,
          equals(3),
        ); // Doctor's Wing, Hygiene Wing, Front Desk (All Zones is null, not in list)
      });

      test('zones are ZoneType enum values', () async {
        // Act
        await waitForRoomsToLoad();

        // Assert - Zones are now enum values, not strings
        final state = container.read(roomNotifierProvider);
        expect(state.zones, contains(ZoneType.doctorsWing));
        expect(state.zones, contains(ZoneType.hygieneWing));
        expect(state.zones, contains(ZoneType.frontDesk));
        expect(state.zones.length, equals(3)); // All ZoneType values
      });
    });

    group('Room Filtering', () {
      setUp(() async {
        // Load rooms before filtering tests
        await waitForRoomsToLoad();
      });

      test('filteredRooms returns all rooms when no zone is selected', () {
        // Arrange
        final state = container.read(roomNotifierProvider);

        // Act
        final filtered = state.filteredRooms;

        // Assert - All rooms returned
        expect(filtered.length, equals(state.rooms.length));
      });

      test('filteredRooms returns all rooms when "All Zones" is selected', () {
        // Arrange
        final notifier = container.read(roomNotifierProvider.notifier);
        notifier.setSelectedZone(null); // null = "All Zones"

        // Act
        final state = container.read(roomNotifierProvider);
        final filtered = state.filteredRooms;

        // Assert - All rooms returned
        expect(filtered.length, equals(state.rooms.length));
      });

      test('setSelectedZone filters rooms by zone', () {
        // Arrange
        final notifier = container.read(roomNotifierProvider.notifier);

        // Act
        notifier.setSelectedZone(ZoneType.doctorsWing);

        // Assert - Only Doctor's Wing rooms
        final state = container.read(roomNotifierProvider);
        final filtered = state.filteredRooms;

        expect(filtered.length, equals(2)); // Exam 1 and Exam 2
        expect(
          filtered.every((room) => room.zone == ZoneType.doctorsWing),
          isTrue,
        );
      });

      test('setSelectedZone updates selected zone in state', () {
        // Arrange
        final notifier = container.read(roomNotifierProvider.notifier);

        // Act
        notifier.setSelectedZone(ZoneType.hygieneWing);

        // Assert
        final state = container.read(roomNotifierProvider);
        expect(state.selectedZone, equals(ZoneType.hygieneWing));
      });

      test('clearZoneFilter resets to null (All Zones)', () {
        // Arrange
        final notifier = container.read(roomNotifierProvider.notifier);
        notifier.setSelectedZone(ZoneType.doctorsWing);

        // Act
        notifier.clearZoneFilter();

        // Assert
        final state = container.read(roomNotifierProvider);
        expect(state.selectedZone, isNull);
      });

      test('getRoomsByZone returns filtered rooms', () {
        // Arrange
        final notifier = container.read(roomNotifierProvider.notifier);

        // Act
        final hygieneRooms = notifier.getRoomsByZone(ZoneType.hygieneWing);

        // Assert - Hygiene 1 and Hygiene 2
        expect(hygieneRooms.length, equals(2));
        expect(
          hygieneRooms.every((room) => room.zone == ZoneType.hygieneWing),
          isTrue,
        );
      });

      test('getRoomsByZone with null returns all rooms', () {
        // Arrange
        final notifier = container.read(roomNotifierProvider.notifier);
        final state = container.read(roomNotifierProvider);

        // Act
        final allRooms = notifier.getRoomsByZone(null);

        // Assert - All rooms returned
        expect(allRooms.length, equals(state.rooms.length));
      });
    });

    group('Room Queries', () {
      setUp(() async {
        // Load rooms before query tests
        await waitForRoomsToLoad();
      });

      test('getActiveRooms returns only rooms with active lights', () {
        // Arrange
        final notifier = container.read(roomNotifierProvider.notifier);

        // Act
        final activeRooms = notifier.getActiveRooms();

        // Assert - Only rooms with active lights
        expect(activeRooms, isNotEmpty);
        expect(activeRooms.every((room) => room.hasActiveLights), isTrue);
      });

      test(
        'getUrgentRooms returns only rooms with urgent/emergency lights',
        () {
          // Arrange
          final notifier = container.read(roomNotifierProvider.notifier);

          // Act
          final urgentRooms = notifier.getUrgentRooms();

          // Assert - Only rooms with urgent lights
          expect(urgentRooms, isNotEmpty);
          expect(urgentRooms.every((room) => room.hasUrgentLights), isTrue);
        },
      );

      test('active rooms have at least one active light', () {
        // Arrange
        final notifier = container.read(roomNotifierProvider.notifier);

        // Act
        final activeRooms = notifier.getActiveRooms();

        // Assert - Each room has active lights
        for (final room in activeRooms) {
          final activeLightCount = room.lights.where((l) => l.isActive).length;
          expect(activeLightCount, greaterThan(0));
        }
      });

      test('active rooms count matches expected from mock data', () {
        // Arrange
        final notifier = container.read(roomNotifierProvider.notifier);

        // Act
        final activeRooms = notifier.getActiveRooms();

        // Assert - Based on MockRoomData: Exam 1, Hygiene 1, Front Desk have active lights
        expect(activeRooms.length, equals(3));
      });
    });

    group('Room Updates', () {
      setUp(() async {
        // Load rooms before update tests
        await waitForRoomsToLoad();
      });

      test('updateRoom modifies specific room in state', () {
        // Arrange
        final notifier = container.read(roomNotifierProvider.notifier);
        final state = container.read(roomNotifierProvider);
        final originalRoom = state.rooms.first;

        // Act - Update room status
        final updatedRoom = originalRoom.copyWith(status: RoomStatus.cleaning);
        notifier.updateRoom(updatedRoom);

        // Assert - Room is updated
        final newState = container.read(roomNotifierProvider);
        final room = newState.rooms.firstWhere((r) => r.id == originalRoom.id);

        expect(room.status, equals(RoomStatus.cleaning));
        expect(room.id, equals(originalRoom.id));
      });

      test('updateRoom preserves other rooms unchanged', () {
        // Arrange
        final notifier = container.read(roomNotifierProvider.notifier);
        final state = container.read(roomNotifierProvider);
        final originalRoom = state.rooms.first;
        final otherRoomsBefore = state.rooms
            .where((r) => r.id != originalRoom.id)
            .toList();

        // Act - Update one room
        final updatedRoom = originalRoom.copyWith(
          status: RoomStatus.maintenance,
        );
        notifier.updateRoom(updatedRoom);

        // Assert - Other rooms unchanged
        final newState = container.read(roomNotifierProvider);
        final otherRoomsAfter = newState.rooms
            .where((r) => r.id != originalRoom.id)
            .toList();

        expect(otherRoomsAfter.length, equals(otherRoomsBefore.length));
        for (var i = 0; i < otherRoomsBefore.length; i++) {
          expect(otherRoomsAfter[i].id, equals(otherRoomsBefore[i].id));
          expect(otherRoomsAfter[i].status, equals(otherRoomsBefore[i].status));
        }
      });
    });

    group('Light Management', () {
      setUp(() async {
        // Load rooms before light tests
        await waitForRoomsToLoad();
      });

      test('activateLight changes light status to active', () async {
        // Arrange
        final notifier = container.read(roomNotifierProvider.notifier);
        final state = container.read(roomNotifierProvider);

        // Find a room with an inactive light (Exam 2 has inactive lights)
        final room = state.rooms.firstWhere(
          (r) => r.lights.any((l) => l.status == LightStatus.inactive),
        );
        final inactiveLight = room.lights.firstWhere(
          (l) => l.status == LightStatus.inactive,
        );

        // Act - Activate the light
        await notifier.activateLight(room.id, inactiveLight.id);

        // Assert - Light is now active
        final newState = container.read(roomNotifierProvider);
        final updatedRoom = newState.rooms.firstWhere((r) => r.id == room.id);
        final updatedLight = updatedRoom.lights.firstWhere(
          (l) => l.id == inactiveLight.id,
        );

        expect(updatedLight.status, equals(LightStatus.active));
        expect(updatedLight.activatedAt, isNotNull);
      });

      test('activateLight sets activatedAt timestamp', () async {
        // Arrange
        final notifier = container.read(roomNotifierProvider.notifier);
        final state = container.read(roomNotifierProvider);
        final room = state.rooms.firstWhere(
          (r) => r.lights.any((l) => l.status == LightStatus.inactive),
        );
        final inactiveLight = room.lights.firstWhere(
          (l) => l.status == LightStatus.inactive,
        );
        final beforeActivation = DateTime.now();

        // Act
        await notifier.activateLight(room.id, inactiveLight.id);

        // Assert - activatedAt is recent
        final newState = container.read(roomNotifierProvider);
        final updatedRoom = newState.rooms.firstWhere((r) => r.id == room.id);
        final updatedLight = updatedRoom.lights.firstWhere(
          (l) => l.id == inactiveLight.id,
        );

        expect(updatedLight.activatedAt, isNotNull);
        expect(
          updatedLight.activatedAt!.isAfter(
            beforeActivation.subtract(const Duration(seconds: 1)),
          ),
          isTrue,
        );
      });

      test('activateLight only affects specified light', () async {
        // Arrange
        final notifier = container.read(roomNotifierProvider.notifier);
        final state = container.read(roomNotifierProvider);
        final room = state.rooms.firstWhere((r) => r.lights.length > 1);
        final targetLight = room.lights.first;
        final otherLightsBefore = room.lights
            .where((l) => l.id != targetLight.id)
            .toList();

        // Act - Activate one light
        await notifier.activateLight(room.id, targetLight.id);

        // Assert - Other lights unchanged
        final newState = container.read(roomNotifierProvider);
        final updatedRoom = newState.rooms.firstWhere((r) => r.id == room.id);
        final otherLightsAfter = updatedRoom.lights
            .where((l) => l.id != targetLight.id)
            .toList();

        expect(otherLightsAfter.length, equals(otherLightsBefore.length));
        for (var i = 0; i < otherLightsBefore.length; i++) {
          expect(
            otherLightsAfter[i].status,
            equals(otherLightsBefore[i].status),
          );
        }
      });

      test('acknowledgeLight changes light status to acknowledged', () async {
        // Arrange
        final notifier = container.read(roomNotifierProvider.notifier);
        final state = container.read(roomNotifierProvider);

        // Find a room with an active light
        final room = state.rooms.firstWhere(
          (r) => r.lights.any((l) => l.status == LightStatus.active),
        );
        final activeLight = room.lights.firstWhere(
          (l) => l.status == LightStatus.active,
        );

        // Act - Acknowledge the light
        await notifier.acknowledgeLight(room.id, activeLight.id);

        // Assert - Light is acknowledged
        final newState = container.read(roomNotifierProvider);
        final updatedRoom = newState.rooms.firstWhere((r) => r.id == room.id);
        final updatedLight = updatedRoom.lights.firstWhere(
          (l) => l.id == activeLight.id,
        );

        expect(updatedLight.status, equals(LightStatus.acknowledged));
      });

      test('acknowledgeLight preserves other light properties', () async {
        // Arrange
        final notifier = container.read(roomNotifierProvider.notifier);
        final state = container.read(roomNotifierProvider);
        final room = state.rooms.firstWhere(
          (r) => r.lights.any((l) => l.status == LightStatus.active),
        );
        final activeLight = room.lights.firstWhere(
          (l) => l.status == LightStatus.active,
        );

        // Act
        await notifier.acknowledgeLight(room.id, activeLight.id);

        // Assert - Other properties preserved
        final newState = container.read(roomNotifierProvider);
        final updatedRoom = newState.rooms.firstWhere((r) => r.id == room.id);
        final updatedLight = updatedRoom.lights.firstWhere(
          (l) => l.id == activeLight.id,
        );

        expect(updatedLight.id, equals(activeLight.id));
        expect(updatedLight.type, equals(activeLight.type));
        expect(updatedLight.label, equals(activeLight.label));
        expect(updatedLight.priority, equals(activeLight.priority));
      });
    });

    group('Refresh Operations', () {
      test('refreshRooms reloads room data', () async {
        // Arrange
        await waitForRoomsToLoad();
        final notifier = container.read(roomNotifierProvider.notifier);

        final stateBefore = container.read(roomNotifierProvider);
        expect(stateBefore.rooms, isNotEmpty);

        // Act - Refresh rooms
        await notifier.refreshRooms();

        // Assert - Rooms are reloaded
        final stateAfter = container.read(roomNotifierProvider);
        expect(stateAfter.rooms, isNotEmpty);
        expect(stateAfter.isLoading, isFalse);
        expect(stateAfter.error, isNull);
      });

      test('refreshRooms maintains room count', () async {
        // Arrange
        await waitForRoomsToLoad();
        final notifier = container.read(roomNotifierProvider.notifier);
        final stateBefore = container.read(roomNotifierProvider);
        final roomCountBefore = stateBefore.rooms.length;

        // Act
        await notifier.refreshRooms();

        // Assert - Same number of rooms
        final stateAfter = container.read(roomNotifierProvider);
        expect(stateAfter.rooms.length, equals(roomCountBefore));
      });
    });

    group('Complete User Scenarios', () {
      test('user can filter rooms by zone and activate lights', () async {
        // Scenario: User selects a zone, views rooms, and activates a light

        // 1. Initial load
        await waitForRoomsToLoad();

        final notifier = container.read(roomNotifierProvider.notifier);
        var state = container.read(roomNotifierProvider);
        expect(state.rooms, isNotEmpty);

        // 2. User filters by Doctor's Wing
        notifier.setSelectedZone(ZoneType.doctorsWing);
        state = container.read(roomNotifierProvider);
        final filteredRooms = state.filteredRooms;
        expect(
          filteredRooms.every((r) => r.zone == ZoneType.doctorsWing),
          isTrue,
        );

        // 3. User finds a room with inactive light
        final room = filteredRooms.firstWhere(
          (r) => r.lights.any((l) => l.status == LightStatus.inactive),
        );
        final inactiveLight = room.lights.firstWhere(
          (l) => l.status == LightStatus.inactive,
        );

        // 4. User activates the light
        await notifier.activateLight(room.id, inactiveLight.id);

        // 5. Verify light is now active
        state = container.read(roomNotifierProvider);
        final updatedRoom = state.rooms.firstWhere((r) => r.id == room.id);
        final activatedLight = updatedRoom.lights.firstWhere(
          (l) => l.id == inactiveLight.id,
        );
        expect(activatedLight.status, equals(LightStatus.active));
      });

      test('user can view urgent rooms and acknowledge lights', () async {
        // Scenario: User checks urgent rooms and acknowledges lights

        // 1. Load rooms
        await waitForRoomsToLoad();

        final notifier = container.read(roomNotifierProvider.notifier);

        // 2. User views urgent rooms
        final urgentRooms = notifier.getUrgentRooms();
        expect(urgentRooms, isNotEmpty);

        // 3. User selects first urgent room with active light
        final urgentRoom = urgentRooms.first;
        final urgentLight = urgentRoom.lights.firstWhere(
          (l) => l.isActive && l.isCritical,
        );

        // 4. User acknowledges the urgent light
        await notifier.acknowledgeLight(urgentRoom.id, urgentLight.id);

        // 5. Verify light is acknowledged
        final state = container.read(roomNotifierProvider);
        final updatedRoom = state.rooms.firstWhere(
          (r) => r.id == urgentRoom.id,
        );
        final acknowledgedLight = updatedRoom.lights.firstWhere(
          (l) => l.id == urgentLight.id,
        );
        expect(acknowledgedLight.status, equals(LightStatus.acknowledged));
      });

      test('state persists across multiple operations', () async {
        // Scenario: User performs multiple actions and state remains consistent

        // 1. Load rooms
        await waitForRoomsToLoad();

        final notifier = container.read(roomNotifierProvider.notifier);
        var state = container.read(roomNotifierProvider);
        final initialRoomCount = state.rooms.length;

        // 2. Filter by zone
        notifier.setSelectedZone(ZoneType.hygieneWing);
        state = container.read(roomNotifierProvider);
        expect(state.selectedZone, equals(ZoneType.hygieneWing));

        // 3. Activate a light (only if there are filtered rooms with lights)
        final filteredRooms = state.filteredRooms;
        if (filteredRooms.isNotEmpty && filteredRooms.first.lights.isNotEmpty) {
          final room = filteredRooms.first;
          final light = room.lights.first;
          await notifier.activateLight(room.id, light.id);
        }

        // 4. Clear filter
        notifier.clearZoneFilter();
        state = container.read(roomNotifierProvider);

        // 5. Verify state consistency
        expect(
          state.rooms.length,
          equals(initialRoomCount),
        ); // Room count unchanged
        expect(state.selectedZone, isNull); // Filter cleared (null = All Zones)
        expect(state.error, isNull); // No errors
        expect(state.isLoading, isFalse); // Not loading
      });
    });

    group('State Management', () {
      test('state copyWith updates only specified fields', () {
        // Arrange
        const originalState = RoomState(
          rooms: [],
          zones: [ZoneType.doctorsWing],
          selectedZone: ZoneType.doctorsWing,
          isLoading: false,
          error: null,
        );

        // Act
        final newState = originalState.copyWith(isLoading: true);

        // Assert
        expect(newState.zones, equals(originalState.zones));
        expect(newState.selectedZone, equals(originalState.selectedZone));
        expect(newState.isLoading, isTrue); // Changed
        expect(newState.error, isNull);
      });

      test('state copyWith with null error clears error', () {
        // Arrange
        const stateWithError = RoomState(error: 'Some error');

        // Act
        final stateWithoutError = stateWithError.copyWith(error: null);

        // Assert
        expect(stateWithoutError.error, isNull);
      });

      test('filteredRooms correctly filters by zone', () {
        // Arrange
        const room1 = Room(
          id: '1',
          name: 'Room 1',
          zone: ZoneType.doctorsWing,
          lights: [],
        );
        const room2 = Room(
          id: '2',
          name: 'Room 2',
          zone: ZoneType.hygieneWing,
          lights: [],
        );
        const state = RoomState(
          rooms: [room1, room2],
          selectedZone: ZoneType.doctorsWing,
        );

        // Act
        final filtered = state.filteredRooms;

        // Assert
        expect(filtered.length, equals(1));
        expect(filtered.first.id, equals('1'));
      });
    });
  });
}
