import 'package:app/domain/model/aircraft_2d.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'domain/estimate_aircraft_screen_positions.dart';
import 'domain/model/events/aircrafts_on_plane_event.dart';

class AircraftsAnnotator extends ConsumerWidget {
  const AircraftsAnnotator({super.key});

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

        final event = snapshot.data as AircraftsOnPlaneEvent;

        return Stack(
          children:
              event.aircrafts
                  .where(_isWithinScreen)
                  .map((aircraft) {
                final posX = aircraft.position.x * 1920;
                final posY = aircraft.position.y * 1080;

                return Positioned(
                  left: posX - 5, // Center the dot
                  top: posY - 5, // Center the dot
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }).toList(),
        );
      },
    );
  }

  bool _isWithinScreen(Aircraft2d aircraft) {
    final x = aircraft.position.x;
    final y = aircraft.position.y;
    return x >= 0 && x <= 1 && y >= 0 && y <= 1;
  }
}
