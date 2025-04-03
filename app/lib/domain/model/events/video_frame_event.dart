import 'package:app/domain/model/events/real_time_event.dart';
import 'package:camera/camera.dart';

class VideoFrameEvent extends RealTimeEvent {
  // todo: don't use CameraImage class because it's from camera plugin
  final CameraImage image;

  VideoFrameEvent({
    required this.image,
    required super.timestamp,
  });

  String get preview => '[${image.width}, ${image.height}]';
}
