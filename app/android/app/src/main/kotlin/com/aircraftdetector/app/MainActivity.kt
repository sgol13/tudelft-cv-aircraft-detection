package com.aircraftdetector.app

import io.flutter.embedding.android.FlutterActivity
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    private val CHANNEL = "camera_fov"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getCameraFoV") {
                val fov = getCameraFoV()
                result.success(fov)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getCameraFoV(): Map<String, Double>? {
        val cameraManager = getSystemService(CAMERA_SERVICE) as CameraManager
        val cameraIdList = cameraManager.cameraIdList

        if (cameraIdList.isNotEmpty()) {
            val cameraId = cameraIdList[0] // Use the first camera - the same as in Flutter Camera plugin
            val characteristics = cameraManager.getCameraCharacteristics(cameraId)

            val focalLengths = characteristics.get(CameraCharacteristics.LENS_INFO_AVAILABLE_FOCAL_LENGTHS)
            val sensorSize = characteristics.get(CameraCharacteristics.SENSOR_INFO_PHYSICAL_SIZE)

            if (focalLengths != null && sensorSize != null) {
                val focalLength = focalLengths[0]

                val verticalFoV = 2 * Math.atan((sensorSize.width.toDouble()) / (2 * focalLength.toDouble()))
                val horizontalFoV = 2 * Math.atan((sensorSize.height.toDouble()) / (2 * focalLength.toDouble()))

                return mapOf("horizontalFoV" to horizontalFoV, "verticalFoV" to verticalFoV)
            }
        }
        return null
    }
}
