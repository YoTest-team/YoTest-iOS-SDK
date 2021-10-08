#!/bin/sh -e

DIR="$( cd "$( dirname "$0"  )" && pwd  )"
cd $DIR

mkdir -p Archive/
mkdir -p Build/

rm -r -f Archive/*
rm -r -f Build/*

scheme="Capture"

xcodebuild archive \
  -project MCGraphics/MCGraphics.xcodeproj \
  -scheme $scheme \
  -destination "generic/platform=iOS" \
  -archivePath Archive/$scheme-iOS \
  VALID_ARCHS="armv7 arm64" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

scheme="Capture"

xcodebuild archive \
  -project MCGraphics/MCGraphics.xcodeproj \
  -scheme $scheme-Simulator \
  -destination "generic/platform=iOS Simulator" \
  -archivePath Archive/$scheme-iOS-Simulator \
  VALID_ARCHS="x86_64" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES


output_name="YoTestSDK"

xcodebuild -create-xcframework \
  -framework Archive/$scheme-iOS.xcarchive/Products/Library/Frameworks/$scheme.framework \
  -framework Archive/$scheme-iOS-Simulator.xcarchive/Products/Library/Frameworks/$scheme.framework \
  -output Build/$output_name.xcframework
