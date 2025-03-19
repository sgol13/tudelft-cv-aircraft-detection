import 'package:app/domain/model/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../port/out/localization_port.dart';

class GpsLocalizationAdapter implements LocalizationPort {

  GpsLocalizationAdapter() {
    _requestLocationPermission();
  }

  @override
  Stream<Location> locationStream() => Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ),
  ).map(_toUserLocation);

  Location _toUserLocation(position) => Location(
    latitude: position.latitude,
    longitude: position.longitude,
    timestamp: position.timestamp,
    altitude: position.altitude,
  );

  void _requestLocationPermission() async {
    PermissionStatus status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }
}

