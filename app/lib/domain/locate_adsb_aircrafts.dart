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
        calculateRelativeAircraftPositions,
      );

  LocatedAircrafts calculateRelativeAircraftPositions(
    AdsbData adsbData,
    UserLocation userLocation,
  ) {
    final locatedAircrafts =
        adsbData.aircrafts
            .map(
              (aircraft) => calculateRelativePosition(aircraft, userLocation),
            )
            .toList();

    return LocatedAircrafts(
      aircrafts: locatedAircrafts,
      timestamp: maxTimestamp(adsbData.timestamp, userLocation.timestamp),
    );
  }

  LocatedAircraft calculateRelativePosition(
    Aircraft aircraft,
    UserLocation userLocation,
  ) {
    const double earthRadius = 6371000; // Earth radius in meters

    // Convert latitude and longitude from degrees to radians
    double lat1 = degToRad(userLocation.latitude);
    double lon1 = degToRad(userLocation.longitude);
    double lat2 = degToRad(aircraft.latitude);
    double lon2 = degToRad(aircraft.longitude);

    // Haversine formula for distance
    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a =
        pow(sin(dLat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    // Compute azimuth (bearing)
    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    double azimuth =
        (radToDeg(atan2(y, x)) + 360) % 360; // Normalize to [0, 360)

    return LocatedAircraft(
      aircraft: aircraft,
      distance: distance,
      azimuth: azimuth,
    );
  }
}

@riverpod
LocateAdsbAircrafts locateAdsbAircrafts(Ref ref) {
  final getCurrentDataStreams = ref.watch(getCurrentDataStreamsProvider);

  return LocateAdsbAircrafts(getCurrentDataStreams);
}
