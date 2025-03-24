import 'package:app/domain/model/events/device_orientation_event.dart';
import 'package:app/port/out/device_orientation_port.dart';
import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';

class FlutterRotationSensorLibAdapter extends DeviceOrientationPort {
  FlutterRotationSensorLibAdapter() {
    config();
  }

  @override
  Stream<DeviceOrientationEvent> get stream =>
      RotationSensor.orientationStream.map(_toDeviceOrientationEvent);

  DeviceOrientationEvent _toDeviceOrientationEvent(OrientationEvent event) {
    return DeviceOrientationEvent(
      timestamp: DateTime.now(),
      rawOrientation: event,
      heading: event.eulerAngles.azimuth,
      pitch: event.eulerAngles.pitch,
      roll: event.eulerAngles.roll,
    );
  }

  void config() {
    RotationSensor.coordinateSystem = CoordinateSystem.transformed(
      Axis3.X,
      -Axis3.Z,
    );
    RotationSensor.samplingPeriod = Duration(milliseconds: 200);
  }
}
