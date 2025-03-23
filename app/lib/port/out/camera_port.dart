import 'package:app/adapter/adsb_lol_api_adapter.dart';
import 'package:app/adapter/camera_adapter.dart';
import 'package:app/domain/model/video_frame_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../device/camera.dart';
import '../../domain/model/adsb_data.dart';
import 'localization_port.dart';

part 'camera_port.g.dart';

abstract class CameraPort {
  Stream<VideoFrameEvent> get stream;
}

@riverpod
CameraPort cameraPort(Ref ref) => CameraAdapter(ref);
