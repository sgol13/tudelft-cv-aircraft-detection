import 'model/device_location_event.dart';
import 'model/device_orientation_event.dart';

abstract class GetDataStreams {
  Stream<DeviceOrientationEvent> get deviceOrientationStream;

  Stream<DeviceLocationEvent> get deviceLocationStream;
}
