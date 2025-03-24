import 'package:app/domain/model/adsb_event.dart';

import 'model/device_location_event.dart';
import 'model/device_orientation_event.dart';
import 'model/video_frame_event.dart';

abstract class GetDataStreams {
  Stream<DeviceOrientationEvent> get deviceOrientationStream;

  Stream<DeviceLocationEvent> get deviceLocationStream;

  Stream<VideoFrameEvent> get cameraStream;

  Stream<AdsbEvent> get adsbStream;
}
