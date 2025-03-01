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

  const SensorData._();

  String get preview =>
      '[${formatValue(x)}, ${formatValue(y)}, ${formatValue(z)}]';

  static String formatValue(double value) =>
      value.toStringAsFixed(3).padLeft(8);
}
