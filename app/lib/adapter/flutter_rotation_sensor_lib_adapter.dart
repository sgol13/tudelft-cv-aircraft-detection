import 'package:app/domain/model/events/device_orientation_event.dart';
import 'package:app/port/out/device_orientation_port.dart';

// Matrix3 is both in vector_math and flutter_rotation_sensor
import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart'
    show OrientationEvent, RotationSensor, CoordinateSystem, Axis3;
import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart'
    as flutter_rotation_sensor
    show Matrix3;
import 'package:vector_math/vector_math.dart' as vector_math show Matrix3;

class FlutterRotationSensorLibAdapter extends DeviceOrientationPort {
  FlutterRotationSensorLibAdapter() {
    _config();
  }

  @override
  Stream<DeviceOrientationEvent> get stream =>
      RotationSensor.orientationStream.map(_toDeviceOrientationEvent);

  DeviceOrientationEvent _toDeviceOrientationEvent(OrientationEvent event) {
    return DeviceOrientationEvent(
      timestamp: DateTime.now(),
      rotationMatrix: _toMatrix3(event.rotationMatrix),
      heading: event.eulerAngles.azimuth,
      pitch: event.eulerAngles.pitch,
      roll: event.eulerAngles.roll,
    );
  }

  // Matrix3 is both in vector_math and flutter_rotation_sensor,
  vector_math.Matrix3 _toMatrix3(flutter_rotation_sensor.Matrix3 m) =>
      vector_math.Matrix3(m[0], m[1], m[2], m[3], m[4], m[5], m[6], m[7], m[8]);

  void _config() {
    // RotationSensor.coordinateSystem = CoordinateSystem.transformed(
    //   Axis3.X,
    //   -Axis3.Z,
    // );
    RotationSensor.samplingPeriod = Duration(milliseconds: 200);
  }
}
