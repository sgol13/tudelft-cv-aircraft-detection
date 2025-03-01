import 'package:app/domain/model/user_location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../port/out/localization_port.dart';

class GpsLocalizationAdapter implements LocalizationPort {

  GpsLocalizationAdapter() {
    _requestLocationPermission();
  }

  @override
  Stream<UserLocation> get locationStream => Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ),
  ).map(_toUserLocation);

  UserLocation _toUserLocation(position) => UserLocation(
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

