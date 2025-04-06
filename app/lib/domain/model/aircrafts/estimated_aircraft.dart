import 'package:app/domain/model/aircrafts/adsb_aircraft.dart';
import 'package:app/domain/model/aircrafts/aircraft_2d.dart';
import 'package:vector_math/vector_math.dart';

class EstimatedAircraft extends Aircraft2d {
  final AdsbAircraft adsb;
  final bool isOnScreen;
  final Vector3 pos3d;
  final double distance;

  EstimatedAircraft({
    required this.adsb,
    required this.isOnScreen,
    required this.pos3d,
    required this.distance,
    required super.pos,
  });

  String get preview =>
      '${adsb.flight} [${(pos.x.toStringAsFixed(3).padLeft(6))}, ${pos.y.toStringAsFixed(3).padLeft(6)}] '
      '[${(pos3d.x.toStringAsFixed(0))}, ${pos3d.y.toStringAsFixed(0)}, ${pos3d.z.toStringAsFixed(0)}]';
}
