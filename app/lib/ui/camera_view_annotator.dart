import 'package:app/domain/model/aircraft_2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math.dart' show Vector2;

import '../domain/estimate_aircraft_screen_positions.dart';
import '../domain/model/events/aircrafts_on_plane_event.dart';

class CameraViewAnnotator extends ConsumerWidget {
  const CameraViewAnnotator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estimateAircraftScreenPositions = ref.watch(
      estimateAircraftScreenPositionsProvider,
    );

    return StreamBuilder(
      stream: estimateAircraftScreenPositions.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading aircraft data...');
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return const Text('No aircraft data');
        }

        final visibleAircrafts =
            (snapshot.data as AircraftsOnPlaneEvent).aircrafts
                .where((aircraft) => aircraft.isOnScreen)
                .toList();

        return RepaintBoundary(
          child: CustomPaint(
            size: Size.infinite,
            painter: AnnotationPainter(visibleAircrafts),
          ),
        );
      },
    );
  }
}

class AnnotationPainter extends CustomPainter {
  final List<Aircraft2d> _aircrafts;
  final Paint _paint = Paint()..color = Colors.purple;

  AnnotationPainter(this._aircrafts);

  @override
  void paint(Canvas canvas, Size size) {
    for (var aircraft in _aircrafts) {
      final offset = _positionToOffset(aircraft.position, size);
      canvas.drawCircle(offset, 5, _paint);

      final textSpan = TextSpan(
        text: aircraft.adsb.flight,
        style: const TextStyle(color: Colors.black, fontSize: 12),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, offset + const Offset(8, -6));
    }
  }

  @override
  bool shouldRepaint(AnnotationPainter oldDelegate) => true;

  Offset _positionToOffset(Vector2 position, Size size) =>
      Offset(position.x * size.width, (1.0 - position.y) * size.height);
}
