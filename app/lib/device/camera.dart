import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CameraNotifier extends StateNotifier<CameraController?> {
  CameraNotifier() : super(null) {
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      final camera = cameras.first;
      final controller = CameraController(
        camera,
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );
      await controller.initialize();
      state = controller;
    }
  }

  @override
  void dispose() {
    state?.dispose();
    super.dispose();
  }
}

final cameraProvider = StateNotifierProvider<CameraNotifier, CameraController?>(
  (ref) {
    return CameraNotifier();
  },
);
