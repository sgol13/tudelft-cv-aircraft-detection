import 'package:app/domain/model/events/device_orientation_event.dart';
import 'package:app/port/out/device_orientation_port.dart';

// Matrix3 is both in vector_math and flutter_rotation_sensor
import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart'
    show OrientationEvent, RotationSensor, CoordinateSystem, Axis3;
import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart'
    as flutter_rotation_sensor
    show Matrix3;
import 'package:vector_math/vector_math.dart' as vector_math show Matrix3;

class MockDeviceOrientationAdapter extends DeviceOrientationPort {
  @override
  Stream<DeviceOrientationEvent> get stream {
    final matrix = flutter_rotation_sensor.Matrix3(
      0.7071068,
      0.7071068,
      0.0000000,
      -0.7071068,
      0.7071068,
      0.0000000,
      0.0000000,
      0.0000000,
      1.0000000,
    );

    return Stream.periodic(Duration(seconds: 1)).map((_) =>
      DeviceOrientationEvent(
        heading: matrix.toEulerAngles().azimuth,
        pitch: matrix.toEulerAngles().pitch,
        roll: matrix.toEulerAngles().roll,
        rotationMatrix: _toMatrix3(matrix),
        timestamp: DateTime.now(),
      ),
    );
  }

  vector_math.Matrix3 _toMatrix3(flutter_rotation_sensor.Matrix3 m) =>
      vector_math.Matrix3(m[0], m[1], m[2], m[3], m[4], m[5], m[6], m[7], m[8]);
}
