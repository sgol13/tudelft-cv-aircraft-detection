import 'package:app/domain/detect_aircrafts/detect_aircrafts.dart';
import 'package:app/domain/detect_aircrafts/ultralytics_live_detect.dart';
import 'package:app/ui/camera_view_annotator.dart';
import 'package:app/ui/ultralytics_camera_preview_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:app/device/camera.dart';
import 'package:ultralytics_yolo/camera_preview/camera_preview.dart';

class CameraView extends ConsumerWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final cameraController = ref.watch(cameraProvider);
    final ultralyticsLiveDetect = ref.watch(detectAircraftsProvider) as UltralyticsLiveDetect;

    return Stack(
      children: [
        // if (cameraController != null && cameraController.value.isInitialized)
        //   CameraPreview(cameraController),
        UltralyticsCameraPreviewWrapper(),

        CameraViewAnnotator(),
      ],
    );
  }
}
