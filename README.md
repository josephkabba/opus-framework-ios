# Opus-iOS

> **IMPORTANT NOTE:**
> 
> This repository contains modified build scripts from the original [Opus-iOS Framework](https://github.com/chrisballinger/Opus-iOS) by Chris Ballinger. The modifications were made to specifically support iOS builds. For the main implementation and original work, please refer to the [original repository](https://github.com/chrisballinger/Opus-iOS).

## About Opus

> Opus is a totally open, royalty-free, highly versatile audio codec. Opus is unmatched for interactive speech and music transmission over the Internet, but is also intended for storage and streaming applications. It is standardized by the Internet Engineering Task Force (IETF) as RFC 6716 which incorporated technology from Skype's SILK codec and Xiph.Org's CELT codec.

## Build Scripts

This repository contains three modified build scripts:

1. `build-libopus-arm.sh` - Builds for both simulator and device architectures
2. `build-libopus-real.sh` - Builds for iOS devices only
3. `build-libopus-sim.sh` - Builds for iOS simulator only

### Usage

From the command line:

```bash
# Build all variants
./build-all-opus.sh

# Copy libraries to your project
./copy-opus-libs.sh [--arm|--real|--sim]
```

## Original Work & License

- Original Repository: [Opus-iOS Framework](https://github.com/chrisballinger/Opus-iOS)
- Author: Chris Ballinger
- Original License: MIT

## Modifications

The build scripts in this repository have been modified to:
- Support selective building for different iOS architectures
- Provide separate builds for simulator and device
- Add verification and build status reporting
- Add copy functionality with validation

For the complete framework implementation and documentation, please refer to the original repository.

## License

This modified version maintains the MIT license from the original work.