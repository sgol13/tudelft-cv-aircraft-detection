import 'package:app/adapter/adsb_lol_api_adapter.dart';
import 'package:app/adapter/camera_adapter.dart';
import 'package:app/adapter/mock/mock_camera_adapter.dart';
import 'package:app/domain/model/camera_fov.dart';
import 'package:app/domain/model/events/video_frame_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../device/camera.dart';
import '../../domain/model/events/adsb_event.dart';
import 'localization_port.dart';

part 'camera_port.g.dart';

abstract class CameraPort {
  Stream<VideoFrameEvent> get stream;

  Future<CameraFoV?> get fieldOfView;

  Future<void> startRecording();

  Future<void> stopRecording(String path);
}

@riverpod
CameraPort cameraPort(Ref ref) => MockCameraAdapter();
