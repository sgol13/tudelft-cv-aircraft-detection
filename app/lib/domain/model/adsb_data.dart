import 'package:app/domain/model/aircraft.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'adsb_data.freezed.dart';

@freezed
class AdsbData with _$AdsbData {
  const factory AdsbData({
    required List<Aircraft> aircrafts,
    required DateTime timestamp,
  }) = _AdsbData;
}