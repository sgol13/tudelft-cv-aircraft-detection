import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_location.freezed.dart';

@freezed
class UserLocation with _$UserLocation {
  const factory UserLocation({
    required double latitude, // [-90, 90]
    required double longitude, // (-180, 180]
    required DateTime timestamp,
    required double altitude, // metres
  }) = _UserLocation;
}