import 'package:app/port/out/localization_port.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:app/port/out/sensors_port.dart';
import 'package:app/domain/model/sensor_data.dart';
import 'package:app/adapter/camera_provider.dart';

import 'domain/get_real_data_streams.dart';
import 'domain/model/user_location.dart';

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
  final Stream<dynamic> stream;
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
    return StreamBuilder<dynamic>(
      stream: widget.stream,
      builder: (context, snapshot) {

        final textStyle = TextStyle(
          color: Colors.white,
          fontFamily: 'Monaco',
          fontSize: 9,
        );

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading ${widget.sensorType} data...', style: textStyle);
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}', style: textStyle);
        } else if (!snapshot.hasData) {
          return Text('No ${widget.sensorType} data available', style: textStyle);
        } else {
          final data = snapshot.data!;

          if (_lastEventTime != null) {
            _frequencyMs =
                data.timestamp.difference(_lastEventTime!).inMilliseconds;
          }
          _lastEventTime = data.timestamp;

          String frequency = _frequencyMs == null ? '' : '${_frequencyMs.toString().padLeft(4)} ms';
          return Text(
            '${widget.sensorType.padLeft(14)} ${data.preview} $frequency',
            textAlign: TextAlign.left,
            style: textStyle,
          );
        }
      },
    );
  }
}

class SensorCameraView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataStreams = ref.watch(getRealDataStreamsProvider);
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
                    stream: dataStreams.streams.accelerometerStream,
                    sensorType: 'Accelerometer',
                  ),
                  SensorDataStreamWidget(
                    stream: dataStreams.streams.gyroscopeStream,
                    sensorType: 'Gyroscope',
                  ),
                  SensorDataStreamWidget(
                    stream: dataStreams.streams.magnetometerStream,
                    sensorType: 'Magnetometer',
                  ),
                  StreamBuilder<UserLocation>(
                    stream: dataStreams.streams.localizationStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Loading Location data...');
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData) {
                        return Text('No Location data available');
                      } else {
                        final location = snapshot.data!;
                        return SensorDataStreamWidget(
                          stream: Stream.value(location),
                          sensorType: 'Location',
                        );
                      }
                    },
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
