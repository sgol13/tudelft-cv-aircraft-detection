import 'package:freezed_annotation/freezed_annotation.dart';

import 'aircraft_in_fov.dart';
import 'located_aircraft.dart';

part 'aircrafts_in_fov.freezed.dart';

@freezed
class AircraftsInFov with _$AircraftsInFov {
  const factory AircraftsInFov({
    required List<AircraftInFov> aircrafts,
    required DateTime timestamp,
  }) = _AircraftsInFov;
}