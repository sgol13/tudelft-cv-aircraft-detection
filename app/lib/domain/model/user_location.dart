import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_location.freezed.dart';

@freezed
class UserLocation with _$UserLocation {
  const factory UserLocation({
    required double latitude, // [-90, 90]
    required double longitude, // (-180, 180]
    required double altitude, // metres
    required DateTime timestamp,
  }) = _UserLocation;

  const UserLocation._();

  String get preview =>
      '[${formatValue(longitude)}, ${formatValue(latitude)}, ${altitude.toStringAsFixed(0).padLeft(6)} m]';

  static String formatValue(double value) =>
      value.toStringAsFixed(4).padLeft(8);
}