import 'package:app/domain/model/events/adsb_event.dart';
import 'package:app/port/out/adsb_port.dart';

import '../../domain/model/adsb_aircraft.dart';
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
    ),
    AdsbAircraft(
      geoLocation: GeoLocation(
        lat: 52.063129,
        lon: 4.470840,
        alt: 0,
      ),
      flight: 'BBB',
    ),
    AdsbAircraft(
      geoLocation: GeoLocation(
        lat: 52.073060,
        lon: 4.394729,
        alt: 0,
      ),
      flight: 'CCC',
    ),
    AdsbAircraft(
      geoLocation: GeoLocation(
        lat: 51.965790,
        lon: 4.256091,
        alt: 10000,
      ),
      flight: 'DDD',
    ),
  ];

  @override
  Stream<AdsbEvent> get stream => Stream.periodic(Duration(seconds: 1)).map(
    (_) => AdsbEvent(aircrafts: _mockedAircrafts, timestamp: DateTime.now()),
  );
}
