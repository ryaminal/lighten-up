// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PatientImpl _$$PatientImplFromJson(Map<String, dynamic> json) =>
    _$PatientImpl(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      middleName: json['middleName'] as String?,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String,
      photoUrl: json['photoUrl'] as String?,
      medicalRecordNumber: json['medicalRecordNumber'] as String?,
      status:
          $enumDecodeNullable(_$PatientStatusEnumMap, json['status']) ??
          PatientStatus.active,
      priority:
          $enumDecodeNullable(_$PatientPriorityEnumMap, json['priority']) ??
          PatientPriority.routine,
      roomNumber: json['roomNumber'] as String?,
      bedNumber: json['bedNumber'] as String?,
      wardLocation: json['wardLocation'] as String?,
      primaryPhysicianId: json['primaryPhysicianId'] as String?,
      primaryPhysicianName: json['primaryPhysicianName'] as String?,
      primaryNurseId: json['primaryNurseId'] as String?,
      primaryNurseName: json['primaryNurseName'] as String?,
      bloodType: json['bloodType'] as String?,
      allergies:
          (json['allergies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      medications:
          (json['medications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      conditions:
          (json['conditions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      insuranceProvider: json['insuranceProvider'] as String?,
      insurancePolicyNumber: json['insurancePolicyNumber'] as String?,
      emergencyContactName: json['emergencyContactName'] as String?,
      emergencyContactPhone: json['emergencyContactPhone'] as String?,
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      admissionDate: json['admissionDate'] == null
          ? null
          : DateTime.parse(json['admissionDate'] as String),
      dischargeDate: json['dischargeDate'] == null
          ? null
          : DateTime.parse(json['dischargeDate'] as String),
      lastVisitDate: json['lastVisitDate'] == null
          ? null
          : DateTime.parse(json['lastVisitDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PatientImplToJson(_$PatientImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'middleName': instance.middleName,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'gender': instance.gender,
      'photoUrl': instance.photoUrl,
      'medicalRecordNumber': instance.medicalRecordNumber,
      'status': _$PatientStatusEnumMap[instance.status]!,
      'priority': _$PatientPriorityEnumMap[instance.priority]!,
      'roomNumber': instance.roomNumber,
      'bedNumber': instance.bedNumber,
      'wardLocation': instance.wardLocation,
      'primaryPhysicianId': instance.primaryPhysicianId,
      'primaryPhysicianName': instance.primaryPhysicianName,
      'primaryNurseId': instance.primaryNurseId,
      'primaryNurseName': instance.primaryNurseName,
      'bloodType': instance.bloodType,
      'allergies': instance.allergies,
      'medications': instance.medications,
      'conditions': instance.conditions,
      'insuranceProvider': instance.insuranceProvider,
      'insurancePolicyNumber': instance.insurancePolicyNumber,
      'emergencyContactName': instance.emergencyContactName,
      'emergencyContactPhone': instance.emergencyContactPhone,
      'notes': instance.notes,
      'metadata': instance.metadata,
      'admissionDate': instance.admissionDate?.toIso8601String(),
      'dischargeDate': instance.dischargeDate?.toIso8601String(),
      'lastVisitDate': instance.lastVisitDate?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$PatientStatusEnumMap = {
  PatientStatus.active: 'active',
  PatientStatus.waiting: 'waiting',
  PatientStatus.inTreatment: 'in_treatment',
  PatientStatus.discharged: 'discharged',
  PatientStatus.admitted: 'admitted',
};

const _$PatientPriorityEnumMap = {
  PatientPriority.routine: 'routine',
  PatientPriority.urgent: 'urgent',
  PatientPriority.critical: 'critical',
};

_$PatientVitalsImpl _$$PatientVitalsImplFromJson(Map<String, dynamic> json) =>
    _$PatientVitalsImpl(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      temperature: (json['temperature'] as num?)?.toDouble(),
      temperatureUnit: json['temperatureUnit'] as String?,
      heartRate: (json['heartRate'] as num?)?.toInt(),
      bloodPressureSystolic: (json['bloodPressureSystolic'] as num?)?.toInt(),
      bloodPressureDiastolic: (json['bloodPressureDiastolic'] as num?)?.toInt(),
      respiratoryRate: (json['respiratoryRate'] as num?)?.toInt(),
      oxygenSaturation: (json['oxygenSaturation'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      weightUnit: json['weightUnit'] as String?,
      height: (json['height'] as num?)?.toDouble(),
      heightUnit: json['heightUnit'] as String?,
      painLevel: json['painLevel'] as String?,
      recordedById: json['recordedById'] as String?,
      recordedByName: json['recordedByName'] as String?,
      notes: json['notes'] as String?,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
    );

Map<String, dynamic> _$$PatientVitalsImplToJson(_$PatientVitalsImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'temperature': instance.temperature,
      'temperatureUnit': instance.temperatureUnit,
      'heartRate': instance.heartRate,
      'bloodPressureSystolic': instance.bloodPressureSystolic,
      'bloodPressureDiastolic': instance.bloodPressureDiastolic,
      'respiratoryRate': instance.respiratoryRate,
      'oxygenSaturation': instance.oxygenSaturation,
      'weight': instance.weight,
      'weightUnit': instance.weightUnit,
      'height': instance.height,
      'heightUnit': instance.heightUnit,
      'painLevel': instance.painLevel,
      'recordedById': instance.recordedById,
      'recordedByName': instance.recordedByName,
      'notes': instance.notes,
      'recordedAt': instance.recordedAt.toIso8601String(),
    };
