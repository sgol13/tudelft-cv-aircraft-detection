import 'dart:math';

import 'package:app/domain/model/user_location.dart';
import 'package:app/port/out/adsb_api_port.dart';
import 'package:app/port/out/localization_port.dart';
import 'package:app/port/out/sensors_port.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';

import 'model/adsb_data.dart';
import 'model/position.dart';
import 'model/sensor_data.dart';

part 'get_real_data_streams.g.dart';

typedef AllDataStreams =
    ({
      Stream<SensorData> accelerometerStream,
      Stream<SensorData> gyroscopeStream,
      Stream<SensorData> magnetometerStream,
      Stream<UserLocation> localizationStream,
      Stream<AdsbData> adsbStream,
      Stream<Position> position,
    });

class GetRealDataStreams {
  final SensorsPort _sensorsPort;
  final LocalizationPort _localizationPort;
  final AdsbApiPort _adsbApiPort;

  double _velocityX = 0;
  double _velocityY = 0;
  double _positionX = 100;
  double _positionY = -100;
  DateTime? _lastTimestamp;

  final double _limitX = 150;
  final double _limitY = 200;

  GetRealDataStreams(
    this._sensorsPort,
    this._localizationPort,
    this._adsbApiPort,
  );

  AllDataStreams get streams => (
    accelerometerStream: _sensorsPort.sensorsStreams.accelerometerStream,
    gyroscopeStream: _sensorsPort.sensorsStreams.gyroscopeStream,
    magnetometerStream: _sensorsPort.sensorsStreams.magnetometerStream,
    localizationStream: _localizationPort.locationStream,
    adsbStream: _adsbApiPort.adsbStream,
    position: positionStream(),
  );

  Stream<Position> positionStream() {
    return _sensorsPort.sensorsStreams.accelerometerStream
        .map((SensorData acc) {
          if (_lastTimestamp == null) {
            _lastTimestamp = acc.timestamp;
            return Position(
              x: _positionX,
              y: _positionY,
              timestamp: acc.timestamp,
            );
          }

          // Compute time difference in seconds
          double dt =
              acc.timestamp
                  .difference(_lastTimestamp!)
                  .inMilliseconds
                  .toDouble() /
              1000;
          _lastTimestamp = acc.timestamp;

          double accX = acc.x;
          double accY = acc.y;

          if (accX.abs() < 0.5) {
            accX = 0;
          }

          if (accY.abs() < 0.5) {
            accY = 0;
          }

          // Update velocity: v = v0 + a * dt
          _velocityX += 1000 * accX * dt;
          _velocityY += 1000 * accY * dt;

          // Update position: s = s0 + v0 * dt + 0.5 * a * dt^2
          _positionX += _velocityX * dt;
          _positionY += _velocityY * dt;

          if (_positionX > _limitX) {
            _positionX = _limitX;
            _velocityX = 0;
          }

          if (_positionX < -_limitX) {
            _positionX = -_limitX;
            _velocityX = 0;
          }

          if (_positionY > _limitY) {
            _positionY = _limitY;
            _velocityY = 0;
          }

          if (_positionY < -_limitY) {
            _positionY = -_limitY;
            _velocityY = 0;
          }

          _positionY = min(max(_positionY, -200), 200);
          _positionX = min(max(_positionX, -150), 150);
          return Position(
            x: _positionX,
            y: _positionY,
            timestamp: acc.timestamp,
          );
        });
  }
}

@riverpod
GetRealDataStreams getRealDataStreams(Ref ref) {
  final sensorsPort = ref.watch(sensorsPortProvider);
  final localizationPort = ref.watch(localizationPortProvider);
  final adsbApiPort = ref.watch(adsbApiPortProvider);

  return GetRealDataStreams(sensorsPort, localizationPort, adsbApiPort);
}
