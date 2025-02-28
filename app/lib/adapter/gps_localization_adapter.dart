import 'package:app/domain/model/user_location.dart';
import 'package:geolocator/geolocator.dart';

class GpsLocalizationAdapter {
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
}
