import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:ultralytics_yolo/ultralytics_yolo_platform_interface.dart';

const String _viewType = 'ultralytics_yolo_camera_preview';

/// A widget that displays the camera preview and run inference on the frames
/// using a Ultralytics YOLO model.
class UltralyticsCameraPreview extends StatefulWidget {
  /// Constructor to create a [UltralyticsCameraPreview].
  const UltralyticsCameraPreview({
    required this.predictor,
    required this.controller,
    required this.onCameraCreated,
    this.boundingBoxesColorList = const [Colors.lightBlueAccent],
    this.classificationOverlay,
    this.loadingPlaceholder,
    super.key,
  });

  /// The predictor used to run inference on the camera frames.
  final Predictor? predictor;

  /// The list of colors used to draw the bounding boxes.
  final List<Color> boundingBoxesColorList;

  /// The classification overlay widget.
  final BaseClassificationOverlay? classificationOverlay;

  /// The controller for the camera preview.
  final UltralyticsYoloCameraController controller;

  /// The callback invoked when the camera is created.
  final VoidCallback onCameraCreated;

  /// The placeholder widget displayed while the predictor is loading.
  final Widget? loadingPlaceholder;

  @override
  State<UltralyticsCameraPreview> createState() => _UltralyticsCameraPreviewState();
}

class _UltralyticsCameraPreviewState extends State<UltralyticsCameraPreview> {

  void _onPlatformViewCreated(_) {
    widget.onCameraCreated();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UltralyticsYoloCameraValue>(
      valueListenable: widget.controller,
      builder: (context, value, child) {
        return Stack(
          children: [
            // Camera preview
            () {
              final creationParams = <String, dynamic>{
                'lensDirection': widget.controller.value.lensDirection,
                'format': widget.predictor?.model.format.name,
              };

              switch (defaultTargetPlatform) {
                case TargetPlatform.android:
                  return AndroidView(
                    viewType: _viewType,
                    onPlatformViewCreated: _onPlatformViewCreated,
                    creationParams: creationParams,
                    creationParamsCodec: const StandardMessageCodec(),
                  );
                case TargetPlatform.iOS:
                  return UiKitView(
                    viewType: _viewType,
                    creationParams: creationParams,
                    onPlatformViewCreated: _onPlatformViewCreated,
                    creationParamsCodec: const StandardMessageCodec(),
                  );
                case TargetPlatform.fuchsia ||
                    TargetPlatform.linux ||
                    TargetPlatform.windows ||
                    TargetPlatform.macOS:
                  return Container();
              }
            }(),

            // Results
            () {
              if (widget.predictor == null) {
                return widget.loadingPlaceholder ?? Container();
              }

              return StreamBuilder(
                stream: (widget.predictor! as ObjectDetector).detectionResultStream,
                builder: (BuildContext context, AsyncSnapshot<List<DetectedObject?>?> snapshot) {
                  if (snapshot.data == null) return Container();

                  return CustomPaint(
                    painter: ObjectDetectorPainter(
                      snapshot.data! as List<DetectedObject>,
                      widget.boundingBoxesColorList,
                      widget.controller.value.strokeWidth,
                    ),
                  );
                },
              );
            }(),
          ],
        );
      },
    );
  }
}
