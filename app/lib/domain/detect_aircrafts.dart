import 'package:app/domain/get_current_data_streams.dart';
import 'package:app/domain/model/detected_aircraft.dart';
import 'package:app/domain/model/detected_aircrafts_event.dart';
import 'package:app/domain/model/video_frame_event.dart';
import 'package:app/port/out/detection_model_port.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class DetectAircrafts {
  final GetCurrentDataStreams _getCurrentDataStreams;
  final DetectionModelPort _detectionModelPort;

  DetectAircrafts(this._getCurrentDataStreams, this._detectionModelPort);

  Stream<DetectedAircraftsEvent> get stream =>
      _getCurrentDataStreams.cameraStream.asyncMap(_processEvent);

  Future<DetectedAircraftsEvent> _processEvent(VideoFrameEvent event) async {
    final detectedAircrafts = await _detectionModelPort.detectAircrafts(event.image);
    return DetectedAircraftsEvent(
      aircrafts: detectedAircrafts,
      timestamp: event.timestamp,
    );
  }
}

@riverpod
DetectAircrafts detectAircrafts(Ref ref) {
  final getCurrentDataStreams = ref.watch(getCurrentDataStreamsProvider);
  final detectionModelPort = ref.watch(detectionModelPortProvider);

  return DetectAircrafts(getCurrentDataStreams, detectionModelPort);
}
