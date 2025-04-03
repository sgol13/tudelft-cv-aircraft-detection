import 'dart:io' as io;
import 'package:app/domain/detect_aircrafts/detect_aircrafts.dart';
import 'package:app/domain/model/events/detected_aircrafts_event.dart';
import 'package:app/domain/model/detected_aircraft.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ultralytics_yolo/yolo_model.dart';
import 'package:vector_math/vector_math.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:ultralytics_yolo/yolo_model.dart';

import 'broadcast_ultralytics_object_detector.dart';

class UltralyticsLiveDetect extends DetectAircrafts {
  static final String _modelPath = "assets/yolov8n_640.tflite";
  static final String _metadataPath = "assets/yolov8n_640_metadata.yaml";

  late final Future<ObjectDetector> detector;

  // final cameraController = UltralyticsYoloCameraController();

  UltralyticsLiveDetect() {
    detector = _initObjectDetectorWithLocalModel();
  }

  @override
  Stream<DetectedAircraftsEvent> get stream =>
      Stream.fromFuture(detector).asBroadcastStream().asyncExpand((detector) {
        return detector.detectionResultStream.whereNotNull().map((event) {
          final aircrafts = event.nonNulls.map(_predictionToAircraft).toList();
          return DetectedAircraftsEvent(aircrafts: aircrafts, timestamp: DateTime.now());
        });
      });


  // @override
  // Stream<DetectedAircraftsEvent> get stream =>
  //     Stream.fromFuture(detector).asBroadcastStream().asyncExpand((detector) {
  //       return detector.detectionResultStream.whereNotNull().map((event) {
  //         final aircrafts = event.nonNulls.map(_predictionToAircraft).toList();
  //         return DetectedAircraftsEvent(aircrafts: aircrafts, timestamp: DateTime.now());
  //       });
  //     });

  // detector.detectionResultStream.whereNotNull().map((event) {
  //   final aircrafts = event.nonNulls.map(_predictionToAircraft).toList();
  //
  //   return DetectedAircraftsEvent(aircrafts: aircrafts, timestamp: DateTime.now());
  // });

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
    final modelPath = await _copy('assets/yolov8n_int8.tflite');
    final metadataPath = await _copy('assets/yolov8n_int8_metadata.yaml');
    final model = LocalYoloModel(
      id: '',
      task: Task.detect,
      format: Format.tflite,
      modelPath: modelPath,
      metadataPath: metadataPath,
    );

    final detector = BroadcastUltralyticsObjectDetector(model: model);

    detector.detectionResultStream.listen((event) {
      print('Detected aircrafts: ${event!.length}');
    });

    detector.loadModel(useGpu: true);

    return ObjectDetector(model: model);
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
