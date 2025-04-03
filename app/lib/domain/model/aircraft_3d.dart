import 'package:app/domain/model/adsb_aircraft.dart';
import 'package:vector_math/vector_math.dart';

class Aircraft3d {
  final AdsbAircraft adsb;
  final Vector3 position;

  Aircraft3d({required this.adsb, required this.position});

  String get preview =>
      '${adsb.flight} [${(position.x.toStringAsFixed(0))}, ${position.y.toStringAsFixed(0)}, ${position.z.toStringAsFixed(0)}]';
}
