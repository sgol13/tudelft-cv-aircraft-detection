import 'package:app/domain/get_current_data_streams.dart';
import 'package:app/domain/model/events/video_frame_event.dart';
import 'package:app/port/out/detection_model_port.dart';
import 'package:rxdart/rxdart.dart';

import 'detect_aircrafts.dart';
import '../model/events/detected_aircrafts_event.dart';

class DetectAircraftsCameraStream extends DetectAircrafts {
  final GetCurrentDataStreams _getCurrentDataStreams;
  final DetectionModelPort _detectionModelPort;

  DetectAircraftsCameraStream(this._getCurrentDataStreams, this._detectionModelPort);

  @override
  Stream<DetectedAircraftsEvent> get stream =>
      _getCurrentDataStreams.cameraStream
          .exhaustMap((event) => Stream.fromFuture(_detectAircraftsInImage(event)))
          .whereNotNull();

  Future<DetectedAircraftsEvent?> _detectAircraftsInImage(VideoFrameEvent event) async {
    final detectedAircrafts = await _detectionModelPort.detectAircrafts(event.image);

    if (detectedAircrafts == null) {
      return null;
    }

    return DetectedAircraftsEvent(aircrafts: detectedAircrafts, timestamp: event.timestamp);
  }
}
