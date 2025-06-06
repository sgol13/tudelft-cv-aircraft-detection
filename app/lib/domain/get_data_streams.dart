import 'package:app/domain/model/events/adsb_event.dart';

import 'model/events/device_location_event.dart';
import 'model/events/device_orientation_event.dart';
import 'model/events/video_frame_event.dart';

abstract class GetDataStreams {
  Stream<DeviceOrientationEvent> get deviceOrientationStream;

  Stream<DeviceLocationEvent> get deviceLocationStream;

  Stream<VideoFrameEvent> get cameraStream;

  Stream<AdsbEvent> get adsbStream;
}
