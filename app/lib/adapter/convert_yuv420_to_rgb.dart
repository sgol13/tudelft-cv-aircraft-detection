import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

// todo: it crashes

final DynamicLibrary nativeLib =
    Platform.isAndroid ? DynamicLibrary.open("libnative-lib.so") : DynamicLibrary.process();

typedef YuvToRgbNative =
    Void Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, Int32, Int32, Pointer<Uint8>);

typedef YuvToRgbDart =
    void Function(Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, int, int, Pointer<Uint8>);

final YuvToRgbDart yuvToRgb =
    nativeLib
        .lookup<NativeFunction<YuvToRgbNative>>('Java_com_example_app_NativeYUVConverter_yuvToRgb')
        .asFunction<YuvToRgbDart>();

Uint8List convertYUV420ToRGB(Uint8List y, Uint8List u, Uint8List v, int width, int height) {
  final Pointer<Uint8> yPtr = calloc.allocate<Uint8>(y.length);
  final Pointer<Uint8> uPtr = calloc.allocate<Uint8>(u.length);
  final Pointer<Uint8> vPtr = calloc.allocate<Uint8>(v.length);
  final Pointer<Uint8> rgbPtr = calloc.allocate<Uint8>(width * height * 3);

  yPtr.asTypedList(y.length).setAll(0, y);
  uPtr.asTypedList(u.length).setAll(0, u);
  vPtr.asTypedList(v.length).setAll(0, v);

  yuvToRgb(yPtr, uPtr, vPtr, width, height, rgbPtr);

  Uint8List rgbBytes = rgbPtr.asTypedList(width * height * 3);

  calloc.free(yPtr);
  calloc.free(uPtr);
  calloc.free(vPtr);
  calloc.free(rgbPtr);

  return rgbBytes;
}
