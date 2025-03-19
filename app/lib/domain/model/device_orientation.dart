import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_orientation.freezed.dart';

@freezed
class DeviceOrientation with _$DeviceOrientation {
  const factory DeviceOrientation({
    required double heading,
    required DateTime timestamp,
  }) = _DeviceOrientation;

  const DeviceOrientation._();

  String get preview =>
      '[${formatValue(heading)}}]';

  static String formatValue(double value) =>
      value.toStringAsFixed(3).padLeft(8);

}
