import 'package:app/domain/model/device_location_event.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../port/out/localization_port.dart';

class GpsLocalizationAdapter implements LocalizationPort {
  GpsLocalizationAdapter() {
    _requestLocationPermission();
  }

  @override
  Stream<DeviceLocationEvent> get stream => Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
    ),
  ).map(_toDeviceLocationEvent);

  DeviceLocationEvent _toDeviceLocationEvent(position) => DeviceLocationEvent(
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
