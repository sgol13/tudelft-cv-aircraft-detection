import 'package:app/domain/get_current_data_streams.dart';
import 'package:app/domain/locate_adsb_aircrafts.dart';
import 'package:app/domain/model/aircraft_in_fov.dart';
import 'package:app/domain/model/aircrafts_in_fov.dart';
import 'package:app/domain/model/device_orientation.dart';
import 'package:app/domain/model/located_aircraft.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

import 'estimate_orientation.dart';
import 'model/aircrafts_in_proximity.dart';

part 'compute_aircraft_screen_positions.g.dart';

class ComputeAircraftScreenPositions {
  static const double _cameraHorizontalFov = 64.0; // for Samsung S21

  final LocateAdsbAircrafts _locateAdsbAircrafts;
  final EstimateOrientation _estimateOrientation;

  ComputeAircraftScreenPositions(
    this._locateAdsbAircrafts,
    this._estimateOrientation,
  );

  Stream<AircraftsInFov> get stream => Rx.combineLatest2<
    AircraftsInProximity,
    DeviceOrientation,
    AircraftsInFov
  >(
    _locateAdsbAircrafts.stream,
    _estimateOrientation.stream,
    _computeAircraftScreenPositions,
  );

  AircraftsInFov _computeAircraftScreenPositions(
    AircraftsInProximity aircraftsInProximity,
    DeviceOrientation deviceOrientation,
  ) => AircraftsInFov(
    aircrafts:
        aircraftsInProximity.aircrafts
            .where((aircraft) => isInFov(aircraft, deviceOrientation))
            .map(
              (aircraft) =>
                  _calculateRelativePosition(aircraft, deviceOrientation),
            )
            .toList(),
    timestamp: deviceOrientation.timestamp,
  );

  bool isInFov(LocatedAircraft aircraft, DeviceOrientation orientation) {
    return aircraft.azimuth >
            orientation.heading - 0.5 * _cameraHorizontalFov &&
        aircraft.azimuth < orientation.heading + 0.5 * _cameraHorizontalFov;
  }

  AircraftInFov _calculateRelativePosition(
    LocatedAircraft aircraft,
    DeviceOrientation orientation,
  ) {
    double relativeX =
        (aircraft.azimuth - orientation.heading + 0.5 * _cameraHorizontalFov) /
        _cameraHorizontalFov;

    return AircraftInFov(
      aircraft: aircraft.adsbAircraft,
      distance: aircraft.distance,
      relativeX: relativeX,
    );
  }
}

@riverpod
ComputeAircraftScreenPositions computeAircraftScreenPositions(Ref ref) {
  final locateAdsbAircrafts = ref.watch(locateAdsbAircraftsProvider);
  final estimateOrientation = ref.watch(estimateOrientationProvider);

  return ComputeAircraftScreenPositions(
    locateAdsbAircrafts,
    estimateOrientation,
  );
}
