import 'package:freezed_annotation/freezed_annotation.dart';

import 'adsb_aircraft.dart';

part 'located_aircraft.freezed.dart';

@freezed
class LocatedAircraft with _$LocatedAircraft {
  const factory LocatedAircraft({
    required AdsbAircraft adsbAircraft,
    required double azimuth,
    required double distance,
  }) = _LocatedAircraft;
}