import 'package:app/domain/get_current_data_streams.dart';
import 'package:app/domain/model/events/device_location_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/estimate_aircraft_2d_positions.dart';
import '../../domain/model/events/aircrafts_on_screen_event.dart';
import '../../domain/model/events/device_orientation_event.dart';

part 'app_streams_port.g.dart';

class AppStreamsPort {
  final GetCurrentDataStreams _getCurrentDataStreams;
  final EstimateAircraft2dPositions _computeAircraft2dPositions;

  AppStreamsPort(this._getCurrentDataStreams, this._computeAircraft2dPositions);

  Stream<AircraftsOnScreenEvent> get adsbAircraftsStream =>
      _computeAircraft2dPositions.stream;

  Stream<DeviceLocationEvent> get locationStream =>
      _getCurrentDataStreams.deviceLocationStream;

  Stream<DeviceOrientationEvent> get orientationStream =>
      _getCurrentDataStreams.deviceOrientationStream;
}

@riverpod
AppStreamsPort appStreamsPort(Ref ref) {
  final getCurrentDataStreams = ref.watch(getCurrentDataStreamsProvider);
  final estimateAircraft2dPositions = ref.watch(
    estimateAircraft2dPositionsProvider,
  );

  return AppStreamsPort(getCurrentDataStreams, estimateAircraft2dPositions);
}
