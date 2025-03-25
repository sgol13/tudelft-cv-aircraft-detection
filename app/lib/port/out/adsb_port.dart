import 'package:app/adapter/adsb_lol_api_adapter.dart';
import 'package:app/adapter/mock/mock_adsb_adapter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/model/events/adsb_event.dart';
import 'localization_port.dart';

part 'adsb_port.g.dart';

abstract class AdsbPort {
  Stream<AdsbEvent> get stream;
}

@riverpod
AdsbPort adsbApiPort(Ref ref) {
  // final localizationPort = ref.read(localizationPortProvider);
  // return AdsbLolApiAdapter(localizationPort);
  return MockAdsbAdapter();
}
