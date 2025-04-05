import 'dart:async';
import 'dart:io';

import 'package:app/domain/model/camera_fov.dart';
import 'package:app/port/out/camera_port.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../device/camera.dart';
import '../domain/model/events/video_frame_event.dart';

class CameraAdapter extends CameraPort {
  final StreamController<VideoFrameEvent> _streamController =
      StreamController<VideoFrameEvent>.broadcast();

  late final ProviderSubscription<CameraController?> _subscription;
  CameraController? _cameraController;

  CameraAdapter(Ref ref) {
    _subscription = ref.listen<CameraController?>(cameraProvider, (
      previous,
      cameraController,
    ) {
      if (cameraController != null && cameraController.value.isInitialized) {
        _initializeStream(cameraController);
        _cameraController = cameraController;
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

  @override
  Future<CameraFoV?> get fieldOfView async {
    try {
      final Map<dynamic, dynamic>? fov = await MethodChannel(
        'camera_fov',
      ).invokeMethod('getCameraFoV');

      if (fov != null) {
        final double horizontalFoV = fov["horizontalFoV"] as double;
        final double verticalFoV = fov["verticalFoV"] as double;

        return CameraFoV(horizontal: horizontalFoV, vertical: verticalFoV);
      }
    } catch (e) {
      print("Error getting camera FoV: $e");
    }
    return null;
  }

  @override
  Future<void> startRecording() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      await _cameraController!.startVideoRecording();
    } else {
      throw Exception("Camera is not initialized");
    }
  }

  @override
  Future<void> stopRecording(String path) async {
    if (_cameraController != null && _cameraController!.value.isRecordingVideo) {
      final XFile videoFile = await _cameraController!.stopVideoRecording();
      final File file = File(videoFile.path);
      await file.copy(path);
    } else {
      throw Exception("Camera is not recording");
    }
  }
}
