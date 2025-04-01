import 'package:app/domain/model/camera_fov.dart';
import 'package:app/domain/model/events/video_frame_event.dart';
import 'package:app/port/out/camera_port.dart';

class MockCameraAdapter extends CameraPort {
  @override
  Future<CameraFoV?> get fieldOfView => throw UnimplementedError();

  @override
  Stream<VideoFrameEvent> get stream => Stream.empty(broadcast: true);
}
