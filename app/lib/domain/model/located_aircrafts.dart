import 'package:freezed_annotation/freezed_annotation.dart';

import 'located_aircraft.dart';

part 'located_aircrafts.freezed.dart';

@freezed
class LocatedAircrafts with _$LocatedAircrafts {
  const factory LocatedAircrafts({
    required List<LocatedAircraft> aircrafts,
    required DateTime timestamp,
  }) = _LocatedAircrafts;
}