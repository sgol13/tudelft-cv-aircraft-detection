import 'package:freezed_annotation/freezed_annotation.dart';

part 'location.freezed.dart';

@freezed
class Location with _$Location {
  const factory Location({
    required double latitude, // [-90, 90]
    required double longitude, // (-180, 180]
    required double altitude, // metres
    required DateTime timestamp,
  }) = _Location;

  const Location._();

  String get preview =>
      '[${formatValue(latitude)}, ${formatValue(longitude)}, ${altitude.toStringAsFixed(0).padLeft(6)} m]';

  static String formatValue(double value) =>
      value.toStringAsFixed(4).padLeft(8);
}