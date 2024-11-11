#!/bin/bash

# Set bash to exit on first error
set -e

# Get current directory
CURRENT_DIR=$(pwd)

# Define the opus version
VERSION="1.3"

# Define output locations
OUTPUTDIR="${CURRENT_DIR}/dependencies-arm"
INTERDIR="${CURRENT_DIR}/build/built"
SRCDIR="${CURRENT_DIR}/build/src"

# Get SDK paths and versions using xcrun
IPHONEOS_SDK_PATH=$(xcrun --sdk iphoneos --show-sdk-path)
SDKVERSION=$(xcrun --sdk iphoneos --show-sdk-version)

# Define compiler
DEVELOPER=$(xcode-select -print-path)
IPHONEOS_CC=$(xcrun -sdk iphoneos -find clang)

# Create directories if they don't exist
mkdir -p "${OUTPUTDIR}/lib"
mkdir -p "${OUTPUTDIR}/include"
mkdir -p "${SRCDIR}"
mkdir -p "${INTERDIR}"

echo "Downloading opus-${VERSION}.tar.gz"
if [ ! -f "${SRCDIR}/opus-${VERSION}.tar.gz" ]; then
    curl -o "${SRCDIR}/opus-${VERSION}.tar.gz" https://archive.mozilla.org/pub/opus/opus-${VERSION}.tar.gz
fi

echo "Using opus-${VERSION}.tar.gz"

# Extract source
cd "${SRCDIR}"
rm -rf "opus-${VERSION}"
tar xzf "opus-${VERSION}.tar.gz"
cd "opus-${VERSION}"

# Build for arm64
echo "Building for arm64"
mkdir -p build-arm64
cd build-arm64
../configure \
    --enable-float-approx \
    --disable-shared \
    --enable-static \
    --with-pic \
    --disable-extra-programs \
    --disable-doc \
    CC="${IPHONEOS_CC}" \
    CFLAGS="-arch arm64 -isysroot ${IPHONEOS_SDK_PATH} -mios-version-min=12.0 -Ofast" \
    LDFLAGS="-arch arm64" \
    --host=arm-apple-darwin \
    --prefix="${INTERDIR}/arm64"

make clean
make -j8
make install
cd ..

# Build for arm64e
echo "Building for arm64e"
mkdir -p build-arm64e
cd build-arm64e
../configure \
    --enable-float-approx \
    --disable-shared \
    --enable-static \
    --with-pic \
    --disable-extra-programs \
    --disable-doc \
    CC="${IPHONEOS_CC}" \
    CFLAGS="-arch arm64e -isysroot ${IPHONEOS_SDK_PATH} -mios-version-min=12.0 -Ofast" \
    LDFLAGS="-arch arm64e" \
    --host=arm-apple-darwin \
    --prefix="${INTERDIR}/arm64e"

make clean
make -j8
make install
cd ..

# Create universal binary
echo "Creating universal binary"
lipo -create \
    "${INTERDIR}/arm64/lib/libopus.a" \
    "${INTERDIR}/arm64e/lib/libopus.a" \
    -output "${OUTPUTDIR}/lib/libopus.a"

# Copy headers
cp -R "${INTERDIR}/arm64/include/"* "${OUTPUTDIR}/include/"

echo "Cleaning up..."
cd "${CURRENT_DIR}"
rm -rf ${INTERDIR}
rm -rf "${SRCDIR}/opus-${VERSION}"
echo "Done."