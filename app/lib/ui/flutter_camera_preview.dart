import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:app/device/camera.dart';

class FlutterCameraPreview extends ConsumerWidget {
  const FlutterCameraPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraController = ref.watch(cameraProvider);

    if (cameraController != null && cameraController.value.isInitialized) {
      return CameraPreview(cameraController);
    } else {
      return Container();
    }
  }
}
