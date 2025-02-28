import 'package:app/domain/model/user_location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../adapter/localization_provider.dart';

@riverpod
Stream<UserLocation> locationStreamPort(Ref ref) {
  return GpsLocalizationAdapter().locationStream;
}