import 'package:app/domain/model/real_time_event.dart';

class DeviceLocationEvent extends RealTimeEvent {
  final double latitude; // [-90, 90]
  final double longitude; // (-180, 180]
  final double altitude;

  DeviceLocationEvent({required super.timestamp, required this.latitude, required this.longitude, required this.altitude}); // metres

  String get preview =>
      '[${formatValue(latitude)}, ${formatValue(longitude)}, ${altitude.toStringAsFixed(0).padLeft(6)} m]';

  static String formatValue(double value) =>
      value.toStringAsFixed(4).padLeft(8);
}
