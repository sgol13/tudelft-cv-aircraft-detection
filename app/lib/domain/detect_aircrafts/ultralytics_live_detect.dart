import 'dart:async';
import 'dart:io' as io;
import 'package:app/domain/detect_aircrafts/detect_aircrafts.dart';
import 'package:app/domain/model/events/detected_aircrafts_event.dart';
import 'package:app/domain/model/detected_aircraft.dart';
import 'package:ultralytics_yolo/yolo_model.dart';
import 'package:vector_math/vector_math.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'broadcast_ultralytics_object_detector.dart';

class UltralyticsLiveDetect extends DetectAircrafts {
  static final String _modelPath = "assets/yolov8n_int8.tflite";
  static final String _metadataPath = "assets/yolov8n_int8_metadata.yaml";

  late final Future<ObjectDetector> detector;

  final StreamController<DetectedAircraftsEvent> _streamController =
      StreamController<DetectedAircraftsEvent>();

  UltralyticsLiveDetect() {
    detector = _initObjectDetectorWithLocalModel();
  }

  @override
  Stream<DetectedAircraftsEvent> get stream => _streamController.stream;

  void addPrediction(List<DetectedObject?>? predictions) {
    if (predictions == null) return;

    final aircrafts = predictions.nonNulls.map(_predictionToAircraft).toList();
    _streamController.add(DetectedAircraftsEvent(aircrafts: aircrafts, timestamp: DateTime.now()));
  }

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

  Future<ObjectDetector> _initObjectDetectorWithLocalModel() async {
    final modelPath = await _copy(_modelPath);
    final metadataPath = await _copy(_metadataPath);
    final model = LocalYoloModel(
      id: '',
      task: Task.detect,
      format: Format.tflite,
      modelPath: modelPath,
      metadataPath: metadataPath,
    );

    final newDetector = BroadcastUltralyticsObjectDetector(model: model);
    newDetector.loadModel(useGpu: true);

    return newDetector;
  }

  Future<String> _copy(String assetPath) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
    await io.Directory(dirname(path)).create(recursive: true);
    final file = io.File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(
        byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );
    }
    return file.path;
  }
}
