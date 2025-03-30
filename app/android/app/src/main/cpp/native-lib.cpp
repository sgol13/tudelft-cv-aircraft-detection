#include <jni.h>
#include <libyuv.h>

extern "C"
JNIEXPORT void JNICALL
Java_com_example_app_NativeYUVConverter_yuvToRgb(
        JNIEnv *env, jclass clazz,
        jbyteArray yData, jbyteArray uData, jbyteArray vData,
        jint width, jint height, jbyteArray rgbOutput) {

    jbyte *yPtr = env->GetByteArrayElements(yData, nullptr);
    jbyte *uPtr = env->GetByteArrayElements(uData, nullptr);
    jbyte *vPtr = env->GetByteArrayElements(vData, nullptr);
    jbyte *rgbPtr = env->GetByteArrayElements(rgbOutput, nullptr);

    libyuv::I420ToRGB24(
        (const uint8_t *) yPtr, width,
        (const uint8_t *) uPtr, width / 2,
        (const uint8_t *) vPtr, width / 2,
        (uint8_t *) rgbPtr, width * 3,
        width, height
    );

    env->ReleaseByteArrayElements(yData, yPtr, JNI_ABORT);
    env->ReleaseByteArrayElements(uData, uPtr, JNI_ABORT);
    env->ReleaseByteArrayElements(vData, vPtr, JNI_ABORT);
    env->ReleaseByteArrayElements(rgbOutput, rgbPtr, 0);
}
