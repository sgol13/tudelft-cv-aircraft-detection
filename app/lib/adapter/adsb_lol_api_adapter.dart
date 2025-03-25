import 'dart:convert';

import 'package:app/domain/model/events/adsb_event.dart';
import 'package:app/domain/model/adsb_aircraft.dart';
import 'package:app/domain/model/events/device_location_event.dart';
import 'package:app/port/out/adsb_api_port.dart';
import 'package:app/port/out/localization_port.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import '../domain/model/geo_location.dart';

class AdsbLolApiAdapter implements AdsbApiPort {
  static final int radius = 20; // nm

  final LocalizationPort _localizationPort;
  DeviceLocationEvent? _lastLocation;

  AdsbLolApiAdapter(this._localizationPort) {
    _localizationPort.stream.listen((location) {
      _lastLocation = location;
    });
  }

  @override
  Stream<AdsbEvent> get stream => Stream.periodic(Duration(seconds: 3))
      .map((_) => _lastLocation)
      .whereNotNull()
      .asyncMap((location) => _fetchDataWithRetry(location, retry: 3))
      .whereNotNull()
      .map(_parseResponse);

  Future<http.Response?> _fetchDataWithRetry(
    DeviceLocationEvent location, {
    required int retry,
  }) async {
    final String url =
        'https://api.adsb.lol/v2/point/${location.latitude}/${location.longitude}/$radius';

    int retryCount = 0;
    while (retryCount < retry) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          return response;
        }
      } catch (e) {}
      retryCount++;
      await Future.delayed(Duration(seconds: 1));
    }
    return null;
  }

  AdsbEvent _parseResponse(http.Response response) {
    final jsonResponse = jsonDecode(response.body);

    final List<AdsbAircraft> aircrafts =
        (jsonResponse['ac'] as List)
            .map((aircraft) => _parseAircraft(aircraft as Map<String, dynamic>))
            .toList();

    return AdsbEvent(aircrafts: aircrafts, timestamp: DateTime.now());
  }

  AdsbAircraft _parseAircraft(Map<String, dynamic> json) => AdsbAircraft(
    geoLocation: GeoLocation(
      latitude: json['lat'],
      longitude: json['lon'],
      altitude: (json['alt_geom'] as num?)?.toDouble() ?? 0.0,
    ),
    flight: json['flight'],
  );
}
