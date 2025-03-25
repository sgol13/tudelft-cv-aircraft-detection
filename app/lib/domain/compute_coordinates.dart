import 'package:app/domain/model/geo_location.dart';
import 'package:vector_math/vector_math.dart';

abstract class ComputeCoordinates {
  Vector3 compute(GeoLocation object, GeoLocation origin);
}
