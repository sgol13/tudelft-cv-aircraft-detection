import 'package:app/domain/model/events/real_time_event.dart';
import 'package:app/domain/model/geo_location.dart';

class DeviceLocationEvent extends RealTimeEvent {
  final GeoLocation geoLocation;

  DeviceLocationEvent({required super.timestamp, required this.geoLocation});

  double get latitude => geoLocation.lat;

  double get longitude => geoLocation.lon;

  double get altitude => geoLocation.alt;

  String get preview =>
      '[${formatValue(latitude)}, ${formatValue(longitude)}, ${altitude.toStringAsFixed(0).padLeft(6)} m]';

  static String formatValue(double value) =>
      value.toStringAsFixed(4).padLeft(8);
}
