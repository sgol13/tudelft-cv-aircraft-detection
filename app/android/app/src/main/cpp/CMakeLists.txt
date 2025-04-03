cmake_minimum_required(VERSION 3.10)
project(libyuv_flutter)

add_library(libyuv STATIC IMPORTED)
set_target_properties(libyuv PROPERTIES IMPORTED_LOCATION
    ${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}/libyuv.a)

add_library(native-lib SHARED native-lib.cpp)

target_include_directories(native-lib PRIVATE ${CMAKE_SOURCE_DIR}/include)
target_link_libraries(native-lib libyuv)