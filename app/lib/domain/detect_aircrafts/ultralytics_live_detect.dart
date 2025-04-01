import 'package:app/domain/detect_aircrafts/detect_aircrafts.dart';
import 'package:app/domain/model/events/detected_aircrafts_event.dart';
import 'package:app/domain/model/detected_aircraft.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ultralytics_yolo/yolo_model.dart';
import 'package:vector_math/vector_math.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

class UltralyticsLiveDetect extends DetectAircrafts {
  static final String _modelPath = "assets/yolov8n_640.tflite";
  static final String _metadataPath = "assets/yolov8n_640_metadata.yaml";

  late final ObjectDetector detector;
  final _cameraController = UltralyticsYoloCameraController();

  UltralyticsLiveDetect() {
    _config();
  }

  @override
  Stream<DetectedAircraftsEvent> get stream =>
      detector.detectionResultStream.whereNotNull().map((event) {
        final aircrafts = event.nonNulls.map(_predictionToAircraft).toList();

        return DetectedAircraftsEvent(aircrafts: aircrafts, timestamp: DateTime.now());
      });

  DetectedAircraft _predictionToAircraft(DetectedObject prediction) {
    final position = Vector2(prediction.boundingBox.center.dx, prediction.boundingBox.center.dy);

    return DetectedAircraft(
      position: position,
      width: prediction.boundingBox.width,
      height: prediction.boundingBox.height,
      classIndex: prediction.index,
      className: prediction.label,
      score: prediction.confidence,
    );
  }

  void _config() async {
    final model = LocalYoloModel(
      id: 'yolov8n',
      task: Task.detect,
      format: Format.tflite,
      modelPath: _modelPath,
      metadataPath: _metadataPath,
    );

    detector = ObjectDetector(model: model);
    detector.loadModel(useGpu: true);
  }
}
