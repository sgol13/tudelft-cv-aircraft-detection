import 'dart:math';

import 'package:app/common.dart';
import 'package:app/domain/get_current_data_streams.dart';
import 'package:app/domain/localize_adsb_aircrafts.dart';
import 'package:app/domain/model/camera_fov.dart';
import 'package:app/domain/model/events/localized_aircrafts_event.dart';
import 'package:app/domain/model/events/aircrafts_on_screen_event.dart';
import 'package:app/domain/model/aircrafts/estimated_aircraft.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vector_math/vector_math.dart';
import 'model/events/device_orientation_event.dart';
import 'model/aircrafts/aircraft_3d.dart';

part 'estimate_aircraft_2d_positions.g.dart';

class EstimateAircraft2dPositions {
  final GetCurrentDataStreams _getCurrentDataStreams;
  final LocalizeAdsbAircrafts _localizeAdsbAircrafts;

  List<Aircraft3d>? _currentAircrafts;
  final CameraFoV _cameraFov = CameraFoV(
    horizontal: degToRad(40.0),
    vertical: degToRad(65.0),
  );

  EstimateAircraft2dPositions(
    this._getCurrentDataStreams,
    this._localizeAdsbAircrafts,
  ) {
    _localizeAdsbAircrafts.stream.listen((LocalizedAircraftsEvent event) {
      _currentAircrafts = event.aircrafts;
    });
  }

  Stream<AircraftsOnScreenEvent> get stream =>
      _getCurrentDataStreams.deviceOrientationStream
          .map(_computeAircraftPositions)
          .whereNotNull();

  AircraftsOnScreenEvent? _computeAircraftPositions(
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

    return AircraftsOnScreenEvent(
      aircrafts: projectedAircrafts,
      timestamp: orientationEvent.timestamp,
    );
  }

  EstimatedAircraft _projectAircraftOntoCameraPlane(
    Aircraft3d aircraft,
    Matrix3 rotationMatrix,
  ) {
    // Rotate the aircraft's relative location into the camera's coordinate system
    final posEnu = aircraft.pos;
    final posCamera = rotationMatrix.transformed(posEnu);

    if (posCamera.z >= 0) {
      return EstimatedAircraft(
        pos: Vector2.zero(),
        adsb: aircraft.adsb,
        pos3d: posCamera,
        isOnScreen: false,
      );
    }

    // Project onto the camera plane using the Pinhole Camera Model
    final x = posCamera.x / -posCamera.z;
    final y = posCamera.y / -posCamera.z;

    // Normalize to [-1, 1] and then shift to [0, 1]
    final xNorm = (x / tan(0.5 * _cameraFov!.horizontal) + 1) * 0.5;
    final yNorm = (y / tan(0.5 * _cameraFov!.vertical) + 1) * 0.5;

    final position2d = Vector2(xNorm, yNorm);

    return EstimatedAircraft(
      pos: position2d,
      adsb: aircraft.adsb,
      pos3d: posCamera,
      isOnScreen: _isOnScreen(position2d),
    );
  }

  bool _isOnScreen(Vector2 pos) {
    return 0 <= pos.x && pos.x <= 1 && 0 <= pos.y && pos.y <= 1;
  }
}

@riverpod
EstimateAircraft2dPositions estimateAircraft2dPositions(Ref ref) {
  final getCurrentDataStreams = ref.watch(getCurrentDataStreamsProvider);
  final localizeAdsbAircrafts = ref.watch(localizeAdsbAircraftsProvider);

  return EstimateAircraft2dPositions(
    getCurrentDataStreams,
    localizeAdsbAircrafts,
  );
}
