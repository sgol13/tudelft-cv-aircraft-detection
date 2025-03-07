import 'package:app/port/out/adsb_api_port.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:app/adapter/camera_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'domain/get_real_data_streams.dart';
import 'domain/model/adsb_data.dart';
import 'domain/model/user_location.dart';
import 'domain/model/position.dart';

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
          CustomPaint(
            size: Size.infinite,
            painter: GridPainter(),
          ),
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
                    stream: dataStreams.streams.position,
                    sensorType: 'Position',
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder<Position>(
            stream: dataStreams.streams.position,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final position = snapshot.data!;
                final screenWidth = MediaQuery.of(context).size.width;
                final screenHeight = MediaQuery.of(context).size.height;

                final centerX = screenWidth / 2;
                final centerY = screenHeight / 2;

                final circleX = centerX + position.x;
                final circleY = centerY + position.y;

                return Positioned(
                  left: circleX - 10,
                  top: circleY - 10,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0;

    final double step = 40.0;

    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class AircraftListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adsbStream = ref.watch(adsbApiPortProvider).adsbStream;

    return Scaffold(
      appBar: AppBar(
        title: Text('Aircraft List'),
      ),
      body: StreamBuilder<AdsbData>(
        stream: adsbStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.aircrafts.isEmpty) {
            return Center(child: Text('No aircrafts available'));
          }

          final aircrafts = snapshot.data!.aircrafts;

          return ListView.builder(
            itemCount: aircrafts.length,
            itemBuilder: (context, index) {
              final aircraft = aircrafts[index];
              return ListTile(
                title: Text(aircraft.flight ?? 'Unknown'),
                subtitle: Text(
                    'Lat: ${aircraft.latitude}, Lon: ${aircraft.longitude}'),
              );
            },
          );
        },
      ),
    );
  }
}