import 'dart:math';

import 'package:app/common.dart';
import 'package:app/domain/get_current_data_streams.dart';
import 'package:app/domain/get_real_data_streams.dart';
import 'package:app/domain/model/aircraft.dart';
import 'package:app/domain/model/located_aircraft.dart';
import 'package:app/port/out/adsb_api_port.dart';
import 'package:app/port/out/localization_port.dart';
import 'package:app/port/out/sensors_port.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

import 'model/adsb_data.dart';
import 'model/located_aircrafts.dart';
import 'model/user_location.dart';

part 'locate_adsb_aircrafts.g.dart';

class LocateAdsbAircrafts {
  final GetCurrentDataStreams _currentDataStreams;

  LocateAdsbAircrafts(this._currentDataStreams);

  Stream<LocatedAircrafts> get stream =>
      Rx.combineLatest2<AdsbData, UserLocation, LocatedAircrafts>(
        _currentDataStreams.streams.adsbStream,
        _currentDataStreams.streams.localizationStream,
        calculatePositions,
      );

  LocatedAircrafts calculatePositions(
    AdsbData adsbData,
    UserLocation userLocation,
  ) {
    final locatedAircrafts =
        adsbData.aircrafts
            .map(
              (aircraft) =>
                  calculateRelativeAircraftPosition(aircraft, userLocation),
            )
            .toList();

    return LocatedAircrafts(
      aircrafts: locatedAircrafts,
      timestamp: maxTimestamp(adsbData.timestamp, userLocation.timestamp),
    );
  }

  LocatedAircraft calculateRelativeAircraftPosition(
    Aircraft aircraft,
    UserLocation userLocation,
  ) {
    return LocatedAircraft(aircraft: aircraft, distance: 0, azimuth: 0);
  }
}

@riverpod
LocateAdsbAircrafts locateAdsbAircrafts(Ref ref) {
  final getCurrentDataStreams = ref.watch(getCurrentDataStreamsProvider);

  return LocateAdsbAircrafts(getCurrentDataStreams);
}
