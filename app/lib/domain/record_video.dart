import 'package:app/domain/estimate_aircraft_2d_positions.dart';
import 'package:app/domain/model/events/aircrafts_on_screen_event.dart';
import 'package:app/port/out/camera_port.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:convert';
import 'dart:io';

part 'record_video.g.dart';

class RecordVideo {
  static final directory = '/storage/emulated/0/Download/aircraft_detection';
  static final videoDir = '$directory/videos';
  static final adsbDir = '$directory/adsb';

  final CameraPort _cameraPort;
  final EstimateAircraft2dPositions _estimateAircraft2dPositions;

  final List<AircraftsOnScreenEvent> _aircraftEvents = [];
  bool _isRecording = false;
  DateTime? _startTime;

  RecordVideo(this._cameraPort, this._estimateAircraft2dPositions) {
    _estimateAircraft2dPositions.stream.listen((event) {
      if (_isRecording) {
        _aircraftEvents.add(event);
      }
    });
  }

  Future<void> startRecording() async {
    await _cameraPort.startRecording();
    _startTime = DateTime.now();
    _isRecording = true;
  }

  Future<void> stopRecording() async {
    await _createDirectory(videoDir);
    await _createDirectory(adsbDir);

    final name = '${DateTime.now().millisecondsSinceEpoch}';
    final videoPath = '$videoDir/$name.mp4';
    final adsbPath = '$adsbDir/$name.json';

    _isRecording = false;
    _cameraPort.stopRecording(videoPath);
    await saveAdsbRecord(adsbPath);
    _aircraftEvents.clear();
  }

  Future<void> saveAdsbRecord(String videoPath) async {
    final predictions = _aircraftEvents.map(_mapEventToJson).toList();

    final record = {'video': videoPath.split('/').last, 'predictions': predictions};

    final recordPath = videoPath.replaceAll('.mp4', '.json');
    final recordFile = File(recordPath);
    await recordFile.writeAsString(jsonEncode(record));
  }

  Map<String, Object> _mapEventToJson(event) {
    final timestamp = event.timestamp.difference(_startTime!).inMilliseconds;
    final aircrafts = event.aircrafts.map(_mapAircraftToJson).toList();

    return {'timestamp': timestamp, 'aircrafts': aircrafts};
  }

  _mapAircraftToJson(aircraft) {
    return {
      'pos': {'x': aircraft.pos.x, 'y': aircraft.pos.y},
      'flight': aircraft.adsb.flight,
      'distance': aircraft.distance,
      'icao_type': aircraft.adsb.icaoType,
      'heading': aircraft.adsb.heading,
      'heading_deg': aircraft.adsb.heading,
      'speed': aircraft.adsb.speed,
      'altitude': aircraft.adsb.geoLocation.alt,
      'latitude': aircraft.adsb.geoLocation.lat,
      'longitude': aircraft.adsb.geoLocation.lon,
    };
  }

  Future<void> _createDirectory(String dir) async {
    final directory = Directory(dir);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }
}

@riverpod
RecordVideo recordVideo(Ref ref) {
  final cameraPort = ref.watch(cameraPortProvider);
  final estimateAircraft2dPositions = ref.watch(estimateAircraft2dPositionsProvider);
  return RecordVideo(cameraPort, estimateAircraft2dPositions);
}
