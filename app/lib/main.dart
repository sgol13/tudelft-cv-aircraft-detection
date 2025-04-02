import 'dart:io' as io;

import 'package:app/ui/ultralytics_camera_preview.dart' show UltralyticsCameraPreview;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ultralytics_yolo/camera_preview/ultralytics_yolo_camera_controller.dart';
import 'package:ultralytics_yolo/camera_preview/ultralytics_yolo_camera_preview.dart';
import 'package:ultralytics_yolo/predict/detect/object_detector.dart';
import 'package:ultralytics_yolo/yolo_model.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = UltralyticsYoloCameraController();
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder<ObjectDetector>(
          future: _initObjectDetectorWithLocalModel(),
          builder: (context, snapshot) {
            final predictor = snapshot.data;

            return predictor == null
                ? Container()
                : UltralyticsCameraPreview(
                  controller: controller,
                  predictor: predictor,
                  onCameraCreated: () {
                    predictor.loadModel(useGpu: true);
                  },
                );
          },
        ),
      ),
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
