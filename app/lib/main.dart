import 'package:app/domain/compute_aircraft_screen_positions.dart';
import 'package:app/domain/model/aircrafts_in_fov.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:app/adapter/camera_provider.dart';

import 'domain/estimate_orientation.dart';
import 'domain/get_current_data_streams.dart';
import 'domain/model/location.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SensorCameraView());
  }
}

class SensorDataStreamWidget extends StatefulWidget {
  final Stream<dynamic> stream;
  final String sensorType;

  const SensorDataStreamWidget({
    super.key,
    required this.stream,
    required this.sensorType,
  });

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
          return Text(
            'No ${widget.sensorType} data available',
            style: textStyle,
          );
        } else {
          final data = snapshot.data!;

          if (_lastEventTime != null) {
            _frequencyMs =
                data.timestamp.difference(_lastEventTime!).inMilliseconds;
          }
          _lastEventTime = data.timestamp;

          String frequency =
              _frequencyMs == null
                  ? ''
                  : '${_frequencyMs.toString().padLeft(4)} ms';
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
  const SensorCameraView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDataStreams = ref.watch(getCurrentDataStreamsProvider);
    final cameraController = ref.watch(cameraProvider);
    final orientationStream = ref.watch(estimateOrientationProvider).stream;
    final aircraftsInFovStream =
        ref.watch(computeAircraftScreenPositionsProvider).stream;

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
                    stream: currentDataStreams.streams.accelerometerStream,
                    sensorType: 'Accelerometer',
                  ),
                  SensorDataStreamWidget(
                    stream: currentDataStreams.streams.gyroscopeStream,
                    sensorType: 'Gyroscope',
                  ),
                  SensorDataStreamWidget(
                    stream: currentDataStreams.streams.magnetometerStream,
                    sensorType: 'Magnetometer',
                  ),
                  StreamBuilder<Location>(
                    stream: currentDataStreams.streams.localizationStream,
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
                  SensorDataStreamWidget(
                    stream: orientationStream,
                    sensorType: 'Orientation',
                  ),
                  StreamBuilder<AircraftsInFov>(
                    stream: aircraftsInFovStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('Loading Aircraft data...');
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData ||
                          snapshot.data!.aircrafts.isEmpty) {
                        return Text('No Aircraft data available');
                      } else {
                        final aircrafts = snapshot.data!.aircrafts;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              aircrafts.map((aircraft) {
                                return Text(
                                  'Flight: ${aircraft.aircraft.flight}, [${aircraft.aircraft.latitude.toStringAsFixed(3)},'
                                      ' ${aircraft.aircraft.longitude.toStringAsFixed(3)}] ${(aircraft.distance / 1000).toStringAsFixed(0)} km, ${aircraft.relativeX.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Monaco',
                                    fontSize: 9,
                                  ),
                                );
                              }).toList(),
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
