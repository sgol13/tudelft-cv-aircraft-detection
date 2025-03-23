import 'dart:async';

import 'package:app/port/out/camera_port.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../device/camera.dart';
import '../domain/model/video_frame_event.dart';

class CameraAdapter extends CameraPort {
  final StreamController<VideoFrameEvent> _streamController =
      StreamController<VideoFrameEvent>.broadcast();

  late final ProviderSubscription<CameraController?> _subscription;

  CameraAdapter(Ref ref) {
    _subscription = ref.listen<CameraController?>(cameraProvider, (
      previous,
      cameraController,
    ) {
      if (cameraController != null && cameraController.value.isInitialized) {
        _initializeStream(cameraController);
      }
    });
  }

  @override
  Stream<VideoFrameEvent> get stream => _streamController.stream;

  void _initializeStream(CameraController cameraController) {
    cameraController.startImageStream((image) {
      final frameEvent = _toVideoFrameEvent(image);
      _streamController.add(frameEvent);
    });
  }

  VideoFrameEvent _toVideoFrameEvent(CameraImage image) =>
      VideoFrameEvent(image: image, timestamp: DateTime.now());

  void dispose() {
    // todo: I'm not sure if it's ever called...
    _streamController.close();
    _subscription.close();
  }
}
