import 'package:freezed_annotation/freezed_annotation.dart';

part 'adsb_aircraft.freezed.dart';

@freezed
class AdsbAircraft with _$AdsbAircraft {
  const factory AdsbAircraft({
    required double latitude,
    required double longitude,
    String? flight,
  }) = _AdsbAircraft;
}