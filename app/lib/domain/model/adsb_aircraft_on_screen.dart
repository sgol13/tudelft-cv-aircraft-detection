import 'package:app/domain/model/adsb_aircraft.dart';
import 'package:vector_math/vector_math.dart';

class AdsbAircraftOnScreen {
  final AdsbAircraft adsb;

  final Vector2 position;

  AdsbAircraftOnScreen({required this.adsb, required this.position});

  String get preview =>
      '${adsb.flight} [${(position.x.toStringAsFixed(3))}, ${position.y.toStringAsFixed(3)}]';
}
