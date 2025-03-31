// import 'package:app/domain/model/detected_aircraft.dart';
// import 'package:app/port/out/detection_model_port.dart';
// import 'package:camera/src/camera_image.dart';
// import 'package:tflite/tflite.dart';
//
// class TfLiteModelAdapter extends DetectionModelPort {
//
//   TfLiteModelAdapter() {
//     _config();
//   }
//
//   @override
//   Future<List<DetectedAircraft>?> detectAircrafts(CameraImage image) async {
//     // TODO: implement detectAircrafts
//     final predictions = Tflite.runModelOnFrame(
//         bytesList: image.planes.map((plane) => plane.bytes).toList(),
//         imageHeight: image.height,
//         imageWidth: image.width,
//         numResults: 10,
//         threshold: 0.1,
//         asynch: false);
//
//     await Future.delayed(Duration(seconds: 1));
//     return Future.value(List.empty());
//   }
//
//
//   void _config() async {
//     await Tflite.loadModel(
//       model: "assets/mobilenet_v1_1.0_224.tflite",
//       labels: "assets/yolov8n_labels.txt",
//       numThreads: 1,
//       isAsset: true,
//       useGpuDelegate: false,
//     );
//   }
// }
