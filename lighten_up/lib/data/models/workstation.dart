import 'package:freezed_annotation/freezed_annotation.dart';

part 'workstation.freezed.dart';
part 'workstation.g.dart';

@freezed
class Workstation with _$Workstation {
  const factory Workstation({
    required String id,
    required String name,
    required String zone,
    required WorkstationStatus status,
    String? description,
  }) = _Workstation;

  factory Workstation.fromJson(Map<String, dynamic> json) =>
      _$WorkstationFromJson(json);
}

enum WorkstationStatus {
  @JsonValue('active')
  active,
  @JsonValue('offline')
  offline,
  @JsonValue('maintenance')
  maintenance,
}
