#!/bin/bash

FRAMEWORK_NAME="IntelliProveSDK"
XCPROJECT="IntelliProve POC.xcodeproj"

# Specify the output path for the XCFramework
XCFRAMEWORK_OUTPUT_PATH="./output/${FRAMEWORK_NAME}.xcframework"

# Specify the temporary directory for copying frameworks
TEMP_DIR="./temp"

# Build the device framework
xcodebuild -project "${XCPROJECT}" -target ${FRAMEWORK_NAME} -configuration Release -sdk iphoneos clean build

# Copy the device framework to a temporary location
mkdir -p ${TEMP_DIR}/iphoneos
cp -R "./build/Release-iphoneos/${FRAMEWORK_NAME}.framework" ${TEMP_DIR}/iphoneos/

# Build the simulator framework
xcodebuild -project "${XCPROJECT}" -target ${FRAMEWORK_NAME} -configuration Release -sdk iphonesimulator clean build

# Copy the simulator framework to a temporary location
mkdir -p ${TEMP_DIR}/iphonesimulator
cp -R "./build/Release-iphonesimulator/${FRAMEWORK_NAME}.framework" ${TEMP_DIR}/iphonesimulator/

# Create the XCFramework
xcodebuild -create-xcframework -framework "${TEMP_DIR}/iphoneos/${FRAMEWORK_NAME}.framework" -framework "${TEMP_DIR}/iphonesimulator/${FRAMEWORK_NAME}.framework" -output ${XCFRAMEWORK_OUTPUT_PATH}

# Clean up
rm -rf "./build"
rm -rf ${TEMP_DIR}

echo "XCFramework created at ${XCFRAMEWORK_OUTPUT_PATH}"
