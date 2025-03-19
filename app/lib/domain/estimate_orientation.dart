import 'dart:math';

import 'package:app/domain/get_current_data_streams.dart';
import 'package:app/domain/model/device_orientation.dart';
import 'package:app/domain/model/sensor_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vector_math/vector_math_64.dart';

part 'estimate_orientation.g.dart';

class EstimateOrientation {
  final GetCurrentDataStreams _currentDataStreams;

  EstimateOrientation(this._currentDataStreams);

  Stream<DeviceOrientation> get stream async* {
    Quaternion orientation = Quaternion.identity();
    Vector3 accel = Vector3.zero();
    Vector3 gyro = Vector3.zero();
    Vector3 magnet = Vector3.zero();
    DateTime? lastTimestamp;

    SensorData? accData;
    SensorData? gyrData;
    SensorData? magData;

    final accelSub = _currentDataStreams.streams.accelerometerStream.listen(
      (data) => accData = data,
    );
    final gyroSub = _currentDataStreams.streams.gyroscopeStream.listen(
      (data) => gyrData = data,
    );
    final magSub = _currentDataStreams.streams.magnetometerStream.listen(
      (data) => magData = data,
    );

    await for (final _ in Stream.periodic(Duration(milliseconds: 20))) {
      if (accData == null || gyrData == null || magData == null) {
        continue;
      }

      accel.setValues(accData!.x, accData!.y, accData!.z);
      gyro.setValues(gyrData!.x, gyrData!.y, gyrData!.z);
      magnet.setValues(magData!.x, magData!.y, magData!.z);

      if (lastTimestamp != null) {
        final dt =
            accData!.timestamp.difference(lastTimestamp).inMicroseconds / 1e6;

        // Integrate gyroscope to estimate orientation change
        Vector3 deltaAngle = gyro * dt;
        Quaternion deltaQ = Quaternion.axisAngle(
          deltaAngle.normalized(),
          deltaAngle.length,
        );
        orientation = orientation * deltaQ;
      }

      lastTimestamp = accData!.timestamp;

      // Normalize accelerometer & magnetometer data
      accel.normalize();
      magnet.normalize();

      // Compute correction using accelerometer and magnetometer
      Quaternion correction = _computeCorrection(accel, magnet);
      orientation = _slerp(orientation, correction, 0.02);

      yield DeviceOrientation.fromQuaternion(orientation, accData!.timestamp);
    }

    await accelSub.cancel();
    await gyroSub.cancel();
    await magSub.cancel();
  }

  Quaternion _computeCorrection(Vector3 accel, Vector3 magnet) {
    // Compute roll and pitch from accelerometer
    double roll = atan2(accel.y, accel.z);
    double pitch = atan2(-accel.x, sqrt(accel.y * accel.y + accel.z * accel.z));

    // Compute yaw from magnetometer
    double yaw = atan2(magnet.y, magnet.x);

    return Quaternion.euler(roll, pitch, yaw);
  }

  Quaternion _slerp(Quaternion q1, Quaternion q2, double t) {
    double dot = q1.x * q2.x + q1.y * q2.y + q1.z * q2.z + q1.w * q2.w;

    // Ensure shortest path interpolation
    if (dot < 0.0) {
      q2 = Quaternion(-q2.x, -q2.y, -q2.z, -q2.w);
      dot = -dot;
    }

    const double threshold = 0.9995;
    if (dot > threshold) {
      // Use linear interpolation for small angles
      Quaternion result =
          Quaternion(
            q1.x + t * (q2.x - q1.x),
            q1.y + t * (q2.y - q1.y),
            q1.z + t * (q2.z - q1.z),
            q1.w + t * (q2.w - q1.w),
          ).normalized();
      return result;
    }

    double theta_0 = acos(dot);
    double theta = theta_0 * t;
    double sinTheta = sin(theta);
    double sinTheta0 = sin(theta_0);

    double s0 = cos(theta) - dot * sinTheta / sinTheta0;
    double s1 = sinTheta / sinTheta0;

    return Quaternion(
      s0 * q1.x + s1 * q2.x,
      s0 * q1.y + s1 * q2.y,
      s0 * q1.z + s1 * q2.z,
      s0 * q1.w + s1 * q2.w,
    );
  }
}

@riverpod
EstimateOrientation estimateOrientation(Ref ref) {
  final getCurrentDataStreams = ref.watch(getCurrentDataStreamsProvider);

  return EstimateOrientation(getCurrentDataStreams);
}
