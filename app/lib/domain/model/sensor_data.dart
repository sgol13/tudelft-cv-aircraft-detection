import 'package:freezed_annotation/freezed_annotation.dart';

part 'sensor_data.freezed.dart';

@freezed
class SensorData with _$SensorData {
  const factory SensorData({
    required double x,
    required double y,
    required double z,
    required DateTime timestamp,
  }) = _SensorData;
}