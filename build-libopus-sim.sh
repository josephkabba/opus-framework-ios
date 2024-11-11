#!/bin/bash

# Set bash to exit on first error
set -e

# Get current directory
CURRENT_DIR=$(pwd)

# Define the opus version
VERSION="1.3"

# Define output locations
OUTPUTDIR="${CURRENT_DIR}/dependencies-sim"
INTERDIR="${CURRENT_DIR}/build/built"
SRCDIR="${CURRENT_DIR}/build/src"

# Get SDK paths and versions using xcrun
IPHONESIMULATOR_SDK_PATH=$(xcrun --sdk iphonesimulator --show-sdk-path)
SDKVERSION=$(xcrun --sdk iphonesimulator --show-sdk-version)

# Define compiler
DEVELOPER=$(xcode-select -print-path)
IPHONESIMULATOR_CC=$(xcrun -sdk iphonesimulator -find clang)

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

# Build for arm64 simulator
echo "Building for arm64 simulator"
mkdir -p build-arm64-sim
cd build-arm64-sim
../configure \
    --enable-float-approx \
    --disable-shared \
    --enable-static \
    --with-pic \
    --disable-extra-programs \
    --disable-doc \
    CC="${IPHONESIMULATOR_CC}" \
    CFLAGS="-arch arm64 -isysroot ${IPHONESIMULATOR_SDK_PATH} -miphonesimulator-version-min=12.0 -Ofast" \
    LDFLAGS="-arch arm64" \
    --host=arm-apple-darwin \
    --prefix="${INTERDIR}/arm64-sim"

make clean
make -j8
make install

# Copy the built library and headers to the output directory
cp "${INTERDIR}/arm64-sim/lib/libopus.a" "${OUTPUTDIR}/lib/"
cp -R "${INTERDIR}/arm64-sim/include" "${OUTPUTDIR}/"

echo "Cleaning up..."
cd "${CURRENT_DIR}"
rm -rf ${INTERDIR}
rm -rf "${SRCDIR}/opus-${VERSION}"
echo "Done."