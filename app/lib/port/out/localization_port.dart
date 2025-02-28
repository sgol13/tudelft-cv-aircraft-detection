import 'package:app/domain/model/user_location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../adapter/gps_localization_adapter.dart';

part 'localization_port.g.dart';

@riverpod
Stream<UserLocation> locationStreamPort(Ref ref) {
  return GpsLocalizationAdapter().locationStream;
}