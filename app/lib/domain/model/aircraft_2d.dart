import 'package:app/domain/model/adsb_aircraft.dart';
import 'package:vector_math/vector_math.dart';

class Aircraft2d {
  final AdsbAircraft adsb;
  final Vector2 position;
  final Vector3 position3d;
  final bool isOnScreen;

  Aircraft2d({
    required this.adsb,
    required this.position,
    required this.position3d,
    required this.isOnScreen,
  });

  String get preview =>
      '${adsb.flight} [${(position.x.toStringAsFixed(3).padLeft(6))}, ${position.y.toStringAsFixed(3).padLeft(6)}] '
      '[${(position3d.x.toStringAsFixed(0))}, ${position3d.y.toStringAsFixed(0)}, ${position3d.z.toStringAsFixed(0)}]';
}
