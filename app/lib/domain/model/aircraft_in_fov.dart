import 'package:freezed_annotation/freezed_annotation.dart';

import 'adsb_aircraft.dart';

part 'aircraft_in_fov.freezed.dart';

@freezed
class AircraftInFov with _$AircraftInFov {
  const factory AircraftInFov({
    required AdsbAircraft aircraft,
    required double relativeX,
    required double distance
  }) = _AircraftInFov;
}