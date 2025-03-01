import 'package:app/domain/model/user_location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../adapter/gps_localization_adapter.dart';

part 'localization_port.g.dart';

abstract class LocalizationPort {
  Stream<UserLocation> get locationStream;
}

@riverpod
LocalizationPort localizationPort(Ref ref) => GpsLocalizationAdapter();