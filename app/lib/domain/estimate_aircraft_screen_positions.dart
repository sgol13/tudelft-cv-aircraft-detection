import 'dart:math';

import 'package:app/common.dart';
import 'package:app/domain/get_current_data_streams.dart';
import 'package:app/domain/localize_adsb_aircrafts.dart';
import 'package:app/domain/model/events/localized_aircrafts_event.dart';
import 'package:app/domain/model/events/aircrafts_on_plane_event.dart';
import 'package:app/domain/model/aircraft_2d.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vector_math/vector_math.dart';

import 'model/events/aircrafts_on_plane_event.dart';
import 'model/events/device_orientation_event.dart';
import 'model/aircraft_3d.dart';

part 'estimate_aircraft_screen_positions.g.dart';

class EstimateAircraftScreenPositions {
  static final double _horizontalFov = degToRad(180.0);
  static final double _verticalFov = degToRad(180.0);

  final GetCurrentDataStreams _getCurrentDataStreams;

  final LocalizeAdsbAircrafts _localizeAdsbAircrafts;

  List<Aircraft3d>? _currentAircrafts;

  EstimateAircraftScreenPositions(
    this._getCurrentDataStreams,
    this._localizeAdsbAircrafts,
  ) {
    _localizeAdsbAircrafts.stream.listen((LocalizedAircraftsEvent event) {
      _currentAircrafts = event.aircrafts;
    });
  }

  Stream<AircraftsOnPlaneEvent> get stream =>
      _getCurrentDataStreams.deviceOrientationStream
          .map(_estimateAircraftPositions)
          .whereNotNull();

  AircraftsOnPlaneEvent? _estimateAircraftPositions(
    DeviceOrientationEvent orientationEvent,
  ) {
    if (_currentAircrafts == null) return null;

    final projectedAircrafts =
        _currentAircrafts!
            .map(
              (aircraft) => _projectAircraftOntoCameraPlane(
                aircraft,
                orientationEvent.rotationMatrix,
              ),
            )
            .toList();

    return AircraftsOnPlaneEvent(
      aircrafts: projectedAircrafts,
      timestamp: orientationEvent.timestamp,
    );
  }

  Aircraft2d _projectAircraftOntoCameraPlane(
    Aircraft3d aircraft,
    Matrix3 rotationMatrix,
  ) {
    // Rotate the aircraft's relative location into the camera's coordinate system
    final posEnu = aircraft.position;
    final posCamera = rotationMatrix.transform(posEnu);

    // Project onto the camera plane using the Pinhole Camera Model
    final x = posCamera.x / posCamera.z;
    final y = posCamera.y / posCamera.z;

    // Normalize to [-1, 1] and then shift to [0, 1]
    final xNorm = (x / tan(0.5 * _horizontalFov) + 1) * 0.5;
    final yNorm = (y / tan(0.5 * _verticalFov) + 1) * 0.5;

    return Aircraft2d(
      position: Vector2(xNorm, yNorm),
      adsb: aircraft.adsb,
    );
  }
}

@riverpod
EstimateAircraftScreenPositions estimateAircraftScreenPositions(Ref ref) {
  final getCurrentDataStreams = ref.watch(getCurrentDataStreamsProvider);
  final localizeAdsbAircrafts = ref.watch(localizeAdsbAircraftsProvider);

  return EstimateAircraftScreenPositions(
    getCurrentDataStreams,
    localizeAdsbAircrafts,
  );
}
