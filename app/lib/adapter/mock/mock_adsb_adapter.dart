import 'package:app/domain/model/events/adsb_event.dart';
import 'package:app/port/out/adsb_port.dart';

import '../../domain/model/aircrafts/adsb_aircraft.dart';
import '../../domain/model/geo_location.dart';

class MockAdsbAdapter extends AdsbPort {
  static const _mockedAircrafts = [
    AdsbAircraft(
      geoLocation: GeoLocation(
        lat: 52.063129,
        lon: 4.470840,
        alt: 5000,
      ),
      flight: 'AAA',
      icaoType: 'A320',
      heading: 180.0,
      speed: 450.0,
    ),
    AdsbAircraft(
      geoLocation: GeoLocation(
        lat: 52.063129,
        lon: 4.470840,
        alt: 0,
      ),
      flight: 'BBB',
      icaoType: 'B737',
      heading: 90.0,
      speed: 0.0,
    ),
    AdsbAircraft(
      geoLocation: GeoLocation(
        lat: 52.073060,
        lon: 4.394729,
        alt: 0,
      ),
      flight: 'CCC',
      icaoType: 'A380',
      heading: 270.0,
      speed: 0.0,
    ),
    AdsbAircraft(
      geoLocation: GeoLocation(
        lat: 51.965790,
        lon: 4.256091,
        alt: 10000,
      ),
      flight: 'DDD',
      icaoType: 'B747',
      heading: 360.0,
      speed: 500.0,
    ),
  ];

  @override
  Stream<AdsbEvent> get stream => Stream.periodic(Duration(seconds: 1)).map(
        (_) => AdsbEvent(aircrafts: _mockedAircrafts, timestamp: DateTime.now()),
  );
}