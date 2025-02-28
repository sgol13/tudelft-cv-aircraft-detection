import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'adapter/camera_provider.dart';
import 'adapter/sensors_provider.dart';

class CameraView extends ConsumerWidget {
  const CameraView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraController = ref.watch(cameraProvider);
    final sensorData = ref.watch(sensorsProvider);

    return Scaffold(
      body: Stack(
        children: [
          cameraController == null
              ? const Center(child: CircularProgressIndicator())
              : CameraPreview(cameraController),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              padding: const EdgeInsets.all(8.0),
              child: sensorData.when(
                data: (data) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Accelerometer: x=${data.accelerometerX?.toStringAsFixed(2)}, y=${data.accelerometerY?.toStringAsFixed(2)}, z=${data.accelerometerZ?.toStringAsFixed(2)}', style: TextStyle(color: Colors.white)),
                    Text('Gyroscope: x=${data.gyroscopeX?.toStringAsFixed(2)}, y=${data.gyroscopeY?.toStringAsFixed(2)}, z=${data.gyroscopeZ?.toStringAsFixed(2)}', style: TextStyle(color: Colors.white)),
                    Text('Magnetometer: x=${data.magnetometerX?.toStringAsFixed(2)}, y=${data.magnetometerY?.toStringAsFixed(2)}, z=${data.magnetometerZ?.toStringAsFixed(2)}', style: TextStyle(color: Colors.white)),
                  ],
                ),
                loading: () => const CircularProgressIndicator(),
                error: (err, stack) => Text('Error: $err', style: TextStyle(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const CameraView(),
    );
  }
}