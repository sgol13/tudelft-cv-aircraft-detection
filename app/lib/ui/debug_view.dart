import 'package:app/port/out/camera_port.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/localize_adsb_aircrafts.dart';
import '../domain/model/events/device_location_event.dart';
import '../port/in/app_streams_port.dart';

class SensorDataStreamWidget extends StatefulWidget {
  final Stream<dynamic> stream;
  final String sensorType;

  const SensorDataStreamWidget({super.key, required this.stream, required this.sensorType});

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
        final textStyle = TextStyle(color: Colors.white, fontFamily: 'Monaco', fontSize: 9);

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading ${widget.sensorType} data...', style: textStyle);
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}', style: textStyle);
        } else if (!snapshot.hasData) {
          return Text('No ${widget.sensorType} data available', style: textStyle);
        } else {
          final data = snapshot.data!;

          if (_lastEventTime != null) {
            _frequencyMs = data.timestamp.difference(_lastEventTime!).inMilliseconds;
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

class DebugView extends ConsumerWidget {
  const DebugView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // todo: remove cameraPort and localizeAdsbAircrafts from here
    final cameraPort = ref.watch(cameraPortProvider);
    final localizeAdsbAircrafts = ref.watch(localizeAdsbAircraftsProvider);

    final appStreamsPort = ref.watch(appStreamsPortProvider);

    return Positioned(
      top: 40,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<DeviceLocationEvent>(
              stream: appStreamsPort.locationStream,
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
              stream: appStreamsPort.orientationStream,
              sensorType: 'Orientation',
            ),
            // SensorDataStreamWidget(stream: cameraPort.stream, sensorType: 'Camera'),
            // SensorDataStreamWidget(
            //   stream: localizeAdsbAircrafts.stream,
            //   sensorType: '',
            // ),
            SensorDataStreamWidget(
              stream: appStreamsPort.adsbAircraftsStream,
              sensorType: 'ADSB',
            ),
            // SensorDataStreamWidget(
            //   stream: appStreamsPort.detectedAircraftsStream,
            //   sensorType: "Detected",
            // ),
          ],
        ),
      ),
    );
  }
}
