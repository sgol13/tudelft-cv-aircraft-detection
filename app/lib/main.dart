import 'dart:io' as io;

import 'package:app/domain/detect_aircrafts/broadcast_ultralytics_object_detector.dart';
import 'package:app/domain/detect_aircrafts/detect_aircrafts.dart';
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

import 'domain/detect_aircrafts/ultralytics_live_detect.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = UltralyticsYoloCameraController();
    final ultralyticsLiveDetect = ref.watch(detectAircraftsProvider) as UltralyticsLiveDetect;

    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder<ObjectDetector>(
          future: ultralyticsLiveDetect.detector,
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
}
