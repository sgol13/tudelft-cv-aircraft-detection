import 'package:app/ui/camera_view_annotator.dart';
import 'package:app/ui/flutter_camera_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CameraView extends ConsumerWidget {
  const CameraView({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 640,
      child: Stack(
        children: [
          // UltralyticsCameraPreviewWrapper(),
          FlutterCameraPreview(),
          EstimatedAircraftsAnnotator(),
        ],
      ),
    );
  }
}
