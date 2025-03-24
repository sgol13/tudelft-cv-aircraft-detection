import 'package:app/adapter/adsb_lol_api_adapter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/model/adsb_event.dart';
import 'localization_port.dart';

part 'adsb_api_port.g.dart';

abstract class AdsbApiPort {
  Stream<AdsbEvent> get stream;
}

@riverpod
AdsbApiPort adsbApiPort(Ref ref) {
  final localizationPort = ref.read(localizationPortProvider);
  return AdsbLolApiAdapter(localizationPort);
}
