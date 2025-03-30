import 'package:app/domain/model/detected_aircraft.dart';
import 'package:app/port/out/detection_model_port.dart';
import 'package:camera/src/camera_image.dart';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'package:processing_camera_image/processing_camera_image.dart';
import 'dart:async' show Future;

import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;

class OnnxModelAdapter extends DetectionModelPort {
  static final String _modelPath = 'assets/yolov8n.onnx';
  final ProcessingCameraImage _processingCameraImage = ProcessingCameraImage();

  late final OrtSession _session;

  OnnxModelAdapter() {
    _config();
  }

  @override
  Future<List<DetectedAircraft>?> detectAircrafts(CameraImage image) async {
    final rgbImage = cameraImageToRgb(image);
    await Future.delayed(Duration(seconds: 1));

    return Future.value(List.empty());
  }

  // void saveImage(CameraImage frame) {
  //   final plane = frame.planes[0];
  //
  //   return Image.fromBytes(
  //     width: frame.width,
  //     height: frame.height,
  //     bytes: plane.bytes.buffer,
  //     rowStride: plane.bytesPerRow,
  //     bytesOffset: IOS_BYTES_OFFSET,
  //     order: frame.bgra,
  //   );
  // }

  imglib.Image? cameraImageToRgb(CameraImage savedImage) =>
    // source: https://pub.dev/packages/processing_camera_image/example
    _processingCameraImage.processCameraImageToRGB(
      bytesPerPixelPlan1: savedImage.planes[1].bytesPerPixel,
      bytesPerRowPlane0: savedImage.planes[0].bytesPerRow,
      bytesPerRowPlane1: savedImage.planes[1].bytesPerRow,
      height: savedImage.height,
      plane0: savedImage.planes[0].bytes,
      plane1: savedImage.planes[1].bytes,
      plane2: savedImage.planes[2].bytes,
      width: savedImage.width,
    );

    void _config() async {
      final sessionOptions = OrtSessionOptions();
      final rawAssetFile = await rootBundle.load(_modelPath);
      final bytes = rawAssetFile.buffer.asUint8List();

      _session = OrtSession.fromBuffer(bytes, sessionOptions!);
    }

    // OrtValueTensor _imageToTensor(CameraImage image) {
    //   final input = image.planes[0].bytes;
    //   final inputSize = image.planes[0].bytes.lengthInBytes;
    //
    //   final inputTensor = OrtValueTensor.createTensorWithDataList(data).fromFloatList(
    //     Float32List.fromList(input),
    //     [1, 3, 416, 416],
    //   );
    //
    //   return inputTensor;
    // }
  }
