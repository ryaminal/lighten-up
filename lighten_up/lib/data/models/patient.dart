import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient.freezed.dart';
part 'patient.g.dart';

/// Patient status in the system
enum PatientStatus {
  @JsonValue('active')
  active,
  @JsonValue('waiting')
  waiting,
  @JsonValue('in_treatment')
  inTreatment,
  @JsonValue('discharged')
  discharged,
  @JsonValue('admitted')
  admitted,
}

/// Patient priority level
enum PatientPriority {
  @JsonValue('routine')
  routine,
  @JsonValue('urgent')
  urgent,
  @JsonValue('critical')
  critical,
}

/// Patient model
@freezed
class Patient with _$Patient {
  const factory Patient({
    required String id,
    required String firstName,
    required String lastName,
    String? middleName,
    required DateTime dateOfBirth,
    required String gender,
    String? photoUrl,
    String? medicalRecordNumber,
    @Default(PatientStatus.active) PatientStatus status,
    @Default(PatientPriority.routine) PatientPriority priority,
    String? roomNumber,
    String? bedNumber,
    String? wardLocation,
    String? primaryPhysicianId,
    String? primaryPhysicianName,
    String? primaryNurseId,
    String? primaryNurseName,
    String? bloodType,
    @Default([]) List<String> allergies,
    @Default([]) List<String> medications,
    @Default([]) List<String> conditions,
    String? insuranceProvider,
    String? insurancePolicyNumber,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? admissionDate,
    DateTime? dischargeDate,
    DateTime? lastVisitDate,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Patient;

  const Patient._();

  factory Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);

  /// Full name helper
  String get fullName {
    if (middleName != null && middleName!.isNotEmpty) {
      return '$firstName $middleName $lastName';
    }
    return '$firstName $lastName';
  }

  /// Initials helper
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  /// Calculate age
  int get age {
    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  /// Age display with units
  String get ageDisplay {
    final years = age;
    if (years < 2) {
      // Show months for infants
      final months = DateTime.now().difference(dateOfBirth).inDays ~/ 30;
      return '$months ${months == 1 ? 'month' : 'months'}';
    }
    return '$years ${years == 1 ? 'year' : 'years'}';
  }

  /// Check if patient is critical
  bool get isCritical => priority == PatientPriority.critical;

  /// Check if patient is currently admitted
  bool get isAdmitted => status == PatientStatus.admitted;

  /// Check if patient is in treatment
  bool get isInTreatment => status == PatientStatus.inTreatment;

  /// Has allergies
  bool get hasAllergies => allergies.isNotEmpty;

  /// Has active medications
  bool get hasMedications => medications.isNotEmpty;

  /// Has medical conditions
  bool get hasConditions => conditions.isNotEmpty;

  /// Location display (room/bed/ward)
  String? get locationDisplay {
    if (roomNumber != null && bedNumber != null) {
      return 'Room $roomNumber, Bed $bedNumber';
    } else if (roomNumber != null) {
      return 'Room $roomNumber';
    } else if (wardLocation != null) {
      return wardLocation;
    }
    return null;
  }

  /// Priority display name
  String get priorityDisplayName {
    switch (priority) {
      case PatientPriority.routine:
        return 'Routine';
      case PatientPriority.urgent:
        return 'Urgent';
      case PatientPriority.critical:
        return 'Critical';
    }
  }

  /// Status display name
  String get statusDisplayName {
    switch (status) {
      case PatientStatus.active:
        return 'Active';
      case PatientStatus.waiting:
        return 'Waiting';
      case PatientStatus.inTreatment:
        return 'In Treatment';
      case PatientStatus.discharged:
        return 'Discharged';
      case PatientStatus.admitted:
        return 'Admitted';
    }
  }
}

/// Patient vitals model
@freezed
class PatientVitals with _$PatientVitals {
  const factory PatientVitals({
    required String id,
    required String patientId,
    double? temperature,
    String? temperatureUnit, // 'C' or 'F'
    int? heartRate,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    int? respiratoryRate,
    double? oxygenSaturation,
    double? weight,
    String? weightUnit, // 'kg' or 'lbs'
    double? height,
    String? heightUnit, // 'cm' or 'in'
    String? painLevel, // 0-10 scale
    String? recordedById,
    String? recordedByName,
    String? notes,
    required DateTime recordedAt,
  }) = _PatientVitals;

  const PatientVitals._();

  factory PatientVitals.fromJson(Map<String, dynamic> json) =>
      _$PatientVitalsFromJson(json);

  /// Blood pressure display
  String? get bloodPressureDisplay {
    if (bloodPressureSystolic != null && bloodPressureDiastolic != null) {
      return '$bloodPressureSystolic/$bloodPressureDiastolic mmHg';
    }
    return null;
  }

  /// Temperature display
  String? get temperatureDisplay {
    if (temperature != null) {
      final unit = temperatureUnit ?? 'C';
      return '${temperature!.toStringAsFixed(1)}°$unit';
    }
    return null;
  }

  /// Check if any vitals are abnormal (basic heuristic)
  bool get hasAbnormalVitals {
    if (heartRate != null && (heartRate! < 60 || heartRate! > 100)) return true;
    if (bloodPressureSystolic != null &&
        (bloodPressureSystolic! < 90 || bloodPressureSystolic! > 140)) {
      return true;
    }
    if (oxygenSaturation != null && oxygenSaturation! < 95) return true;
    return false;
  }
}
