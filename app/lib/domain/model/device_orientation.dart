import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vector_math/vector_math_64.dart';

part 'device_orientation.freezed.dart';

@freezed
class DeviceOrientation with _$DeviceOrientation {
  const factory DeviceOrientation({
    required double x,
    required double y,
    required double z,
    required double w,
    required DateTime timestamp,
  }) = _DeviceOrientation;

  const DeviceOrientation._();

  static DeviceOrientation fromQuaternion(Quaternion q, DateTime timestamp) {
    return DeviceOrientation(
      x: q.x,
      y: q.y,
      z: q.z,
      w: q.w,
      timestamp: timestamp,
    );
  }

  String get preview =>
      '[${formatValue(x)}, ${formatValue(y)}, ${formatValue(z)}, ${formatValue(w)}]';

  static String formatValue(double value) =>
      value.toStringAsFixed(3).padLeft(8);

}
