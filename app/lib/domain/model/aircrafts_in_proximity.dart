import 'package:freezed_annotation/freezed_annotation.dart';

import 'located_aircraft.dart';

part 'aircrafts_in_proximity.freezed.dart';

@freezed
class AircraftsInProximity with _$AircraftsInProximity {
  const factory AircraftsInProximity({
    required List<LocatedAircraft> aircrafts,
    required DateTime timestamp,
  }) = _AircraftsInProximity;
}