import 'package:lighten_up/data/models/room.dart';

/// Mock data for rooms - will be replaced with actual API calls
/// Separated from UI components to follow Single Responsibility Principle
class MockRoomData {
  MockRoomData._();

  /// Get mock rooms for development/testing
  static List<Room> getRooms() {
    return [
      Room(
        id: '1',
        name: 'Exam 1',
        status: RoomStatus.occupied,
        zone: ZoneType.doctorsWing,
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
        zone: ZoneType.doctorsWing,
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
        zone: ZoneType.hygieneWing,
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
        zone: ZoneType.hygieneWing,
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
        zone: ZoneType.frontDesk,
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
  }
}
