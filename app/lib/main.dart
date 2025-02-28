import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:app/port/out/sensors_port.dart';
import 'package:app/domain/model/sensor_data.dart';
import 'package:app/adapter/camera_provider.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SensorCameraView());
  }
}

class SensorDataStreamWidget extends StatefulWidget {
  final Stream<SensorData> stream;
  final String sensorType;

  const SensorDataStreamWidget({
    Key? key,
    required this.stream,
    required this.sensorType,
  }) : super(key: key);

  @override
  _SensorDataStreamWidgetState createState() => _SensorDataStreamWidgetState();
}

class _SensorDataStreamWidgetState extends State<SensorDataStreamWidget> {
  DateTime? _lastEventTime;
  int? _frequencyMs;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SensorData>(
      stream: widget.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading ${widget.sensorType} data...');
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return Text('No ${widget.sensorType} data available');
        } else {
          final data = snapshot.data!;
          final currentTime = DateTime.now();

          if (_lastEventTime != null) {
            _frequencyMs =
                currentTime.difference(_lastEventTime!).inMilliseconds;
          }
          _lastEventTime = currentTime;

          String x = data.x.toStringAsFixed(3).padLeft(7);
          String y = data.y.toStringAsFixed(3).padLeft(7);
          String z = data.z.toStringAsFixed(3).padLeft(7);

          return Text(
            '${widget.sensorType.padLeft(14)} [$x, $y, $z] $_frequencyMs ms',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Monaco',
              fontSize: 10,
            ),
          );
        }
      },
    );
  }
}

class SensorCameraView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorsDataStreams = ref.watch(sensorsStreamsPortProvider);
    final cameraController = ref.watch(cameraProvider);

    return Scaffold(
      body: Stack(
        children: [
          if (cameraController != null && cameraController.value.isInitialized)
            CameraPreview(cameraController),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SensorDataStreamWidget(
                    stream: sensorsDataStreams.accelerometerStream,
                    sensorType: 'Accelerometer',
                  ),
                  SensorDataStreamWidget(
                    stream: sensorsDataStreams.gyroscopeStream,
                    sensorType: 'Gyroscope',
                  ),
                  SensorDataStreamWidget(
                    stream: sensorsDataStreams.magnetometerStream,
                    sensorType: 'Magnetometer',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
