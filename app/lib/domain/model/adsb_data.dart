import 'package:app/domain/model/adsb_aircraft.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'adsb_data.freezed.dart';

@freezed
class AdsbData with _$AdsbData {
  const factory AdsbData({
    required List<AdsbAircraft> aircrafts,
    required DateTime timestamp,
  }) = _AdsbData;
}