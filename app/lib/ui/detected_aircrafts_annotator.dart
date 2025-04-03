import 'package:app/domain/model/aircrafts/detected_aircraft.dart';
import 'package:app/domain/model/aircrafts/estimated_aircraft.dart';
import 'package:app/domain/model/events/detected_aircrafts_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

import '../domain/detect_aircrafts/detect_aircrafts.dart';
import '../domain/estimate_aircraft_2d_positions.dart';
import '../domain/model/events/aircrafts_on_screen_event.dart';
import '../port/in/app_streams_port.dart';

class DetectedAircraftsAnnotator extends ConsumerWidget {
  const DetectedAircraftsAnnotator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStreamsPort = ref.watch(appStreamsPortProvider);

    return StreamBuilder(
      stream: appStreamsPort.detectedAircraftsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading detected aircraft data...');
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return const Text('No detected aircraft data');
        }

        final aircrafts = (snapshot.data as DetectedAircraftsEvent).aircrafts;

        return RepaintBoundary(
          child: CustomPaint(size: Size.infinite, painter: AnnotationPainter(aircrafts)),
        );
      },
    );
  }
}

class AnnotationPainter extends CustomPainter {
  final List<DetectedAircraft> _aircrafts;
  final Paint _paint = Paint()..color = Colors.orange;

  AnnotationPainter(this._aircrafts);

  @override
  void paint(Canvas canvas, Size size) {
    for (var aircraft in _aircrafts) {
      final offset = _positionToOffset(aircraft.pos, size);
      canvas.drawCircle(offset, 5, _paint);

      final textSpan = TextSpan(
        text: aircraft.className,
        style: const TextStyle(color: Colors.black, fontSize: 12),
      );
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, offset + const Offset(8, -6));
    }
  }

  @override
  bool shouldRepaint(AnnotationPainter oldDelegate) => true;

  Offset _positionToOffset(Vector2 position, Size size) =>
      Offset(position.x * size.width, position.y * size.height);
}
