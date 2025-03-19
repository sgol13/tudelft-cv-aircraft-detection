import 'package:app/domain/get_real_data_streams.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


part 'get_current_data_streams.g.dart';

class GetCurrentDataStreams {
  final GetRealDataStreams _getRealDataStreams;

  GetCurrentDataStreams(this._getRealDataStreams);

  AllDataStreams get streams => _getRealDataStreams.streams;
}

@riverpod
GetCurrentDataStreams getCurrentDataStreams(Ref ref) {
  final getRealDataStreams = ref.watch(getRealDataStreamsProvider);

  return GetCurrentDataStreams(getRealDataStreams);
}
