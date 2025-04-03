import 'package:app/domain/detect_aircrafts/detect_aircrafts.dart';
import 'package:app/ui/ultralytics_camera_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultralytics_yolo/camera_preview/ultralytics_yolo_camera_controller.dart';
import 'package:ultralytics_yolo/predict/detect/object_detector.dart';

import '../domain/detect_aircrafts/ultralytics_live_detect.dart';

class UltralyticsCameraPreviewWrapper extends ConsumerWidget {
  const UltralyticsCameraPreviewWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = UltralyticsYoloCameraController();
    final ultralyticsLiveDetect = ref.watch(detectAircraftsProvider) as UltralyticsLiveDetect;

    return FutureBuilder<ObjectDetector>(
      future: ultralyticsLiveDetect.detector,
      builder: (context, snapshot) {
        final predictor = snapshot.data;

        return predictor == null
            ? Container()
            : UltralyticsCameraPreview(
              controller: controller,
              predictor: predictor,
              liveDetect: ultralyticsLiveDetect,
            );
      },
    );
  }
}
