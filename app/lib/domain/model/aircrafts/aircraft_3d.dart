import 'package:app/domain/model/aircrafts/adsb_aircraft.dart';
import 'package:vector_math/vector_math.dart';

class Aircraft3d {
  final AdsbAircraft adsb;
  final Vector3 pos;

  Aircraft3d({required this.adsb, required this.pos});

  String get preview =>
      '${adsb.flight} [${(pos.x.toStringAsFixed(0))}, ${pos.y.toStringAsFixed(0)}, ${pos.z.toStringAsFixed(0)}]';
}
