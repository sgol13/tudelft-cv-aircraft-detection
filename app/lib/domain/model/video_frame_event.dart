import 'package:app/domain/model/real_time_event.dart';
import 'package:camera/camera.dart';

class VideoFrameEvent extends RealTimeEvent {
  final CameraImage image;

  VideoFrameEvent({
    required this.image,
    required super.timestamp,
  });

  String get preview => '[${image.width}, ${image.height}]';
}
