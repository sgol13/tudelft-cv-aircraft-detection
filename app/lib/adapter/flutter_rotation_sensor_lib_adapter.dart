import 'package:app/domain/model/events/device_orientation_event.dart';
import 'package:app/port/out/device_orientation_port.dart';
import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart'
    show OrientationEvent, RotationSensor, CoordinateSystem, Axis3;
import 'package:vector_math/vector_math.dart' show Matrix3;

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
  Matrix3 _toMatrix3(dynamic matrix3) => Matrix3(
    matrix3[0][0],
    matrix3[0][1],
    matrix3[0][2],
    matrix3[1][0],
    matrix3[1][1],
    matrix3[1][2],
    matrix3[2][0],
    matrix3[2][1],
    matrix3[2][2],
  );

  void _config() {
    RotationSensor.coordinateSystem = CoordinateSystem.transformed(
      Axis3.X,
      -Axis3.Z,
    );
    RotationSensor.samplingPeriod = Duration(milliseconds: 200);
  }
}
