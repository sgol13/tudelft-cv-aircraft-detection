import 'dart:ffi';
import 'dart:typed_data';

import 'package:app/domain/model/aircrafts/detected_aircraft.dart';
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
  final _runOptions = OrtRunOptions();

  OnnxModelAdapter() {
    _config();
  }

  @override
  Future<List<DetectedAircraft>?> detectAircrafts(CameraImage image) async {
    final rgbImage = cameraImageToRgb(image);
    final inputTensor = await _imageToTensor(rgbImage!);
    await Future.delayed(Duration(seconds: 1));

    final inputs = {'images': inputTensor};
    final results = _session.run(_runOptions, inputs);

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

  Future<OrtValueTensor> _imageToTensor(imglib.Image image) async {
    final width = image.width;
    final height = image.height;

    final Float32List inputData = Float32List(width * height * 3);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = image.getPixel(x, y);

        inputData[(y * width + x)] = pixel.r / 255.0; // R channel
        inputData[(width * height) + (y * width + x)] = pixel.g / 255.0; // G channel
        inputData[(width * height * 2) + (y * width + x)] = pixel.b / 255.0; // B channel
      }
    }

    return OrtValueTensor.createTensorWithDataList(inputData, [1, 3, width, height]);
  }
}
