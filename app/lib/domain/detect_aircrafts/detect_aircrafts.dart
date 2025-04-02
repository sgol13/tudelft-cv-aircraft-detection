import 'package:app/domain/detect_aircrafts/detect_aircrafts_camera_stream.dart';
import 'package:app/domain/detect_aircrafts/ultralytics_live_detect.dart';
import 'package:app/domain/get_current_data_streams.dart';
import 'package:app/domain/model/events/video_frame_event.dart';
import 'package:app/port/out/detection_model_port.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

import '../model/events/detected_aircrafts_event.dart';

part 'detect_aircrafts.g.dart';

abstract class DetectAircrafts {
  Stream<DetectedAircraftsEvent> get stream;
}

@riverpod
DetectAircrafts detectAircrafts(Ref ref) {
  final getCurrentDataStreams = ref.watch(getCurrentDataStreamsProvider);
  final detectionModelPort = ref.watch(detectionModelPortProvider);

  return DetectAircraftsCameraStream(getCurrentDataStreams, detectionModelPort);
}

// @riverpod
// DetectAircrafts detectAircrafts(Ref ref) => UltralyticsLiveDetect();
