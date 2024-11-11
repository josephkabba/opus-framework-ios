#!/bin/bash

# Set bash to exit on first error
set -e

# Get current directory
CURRENT_DIR=$(pwd)

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Print header function
print_header() {
    echo -e "\n${BOLD}${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}   $1${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}\n"
}

# Print section function
print_section() {
    echo -e "\n${CYAN}▶ $1${NC}"
}

# Function to get architecture info
get_arch_info() {
    local file=$1
    if [ -f "$file" ]; then
        echo $(lipo -info "$file" | sed 's/^.*are: //')
    else
        echo "File not found"
    fi
}

# Function to get file size
get_file_size() {
    local file=$1
    if [ -f "$file" ]; then
        echo $(ls -lh "$file" | awk '{print $5}')
    else
        echo "File not found"
    fi
}

# Set permissions
print_header "Setting Execute Permissions"
echo -e "${YELLOW}chmod +x build-libopus-arm.sh${NC}"
chmod +x build-libopus-arm.sh
echo -e "${YELLOW}chmod +x build-libopus-real.sh${NC}"
chmod +x build-libopus-real.sh
echo -e "${YELLOW}chmod +x build-libopus-sim.sh${NC}"
chmod +x build-libopus-sim.sh
echo -e "${GREEN}✓ All permissions set${NC}"

# Function to run build script and check result
run_build() {
    local script=$1
    local description=$2
    
    print_header "Building $description"
    
    if ./$script; then
        echo -e "\n${GREEN}══════════════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}✓ Successfully built${NC} ${BOLD}$description${NC}"
        echo -e "${GREEN}══════════════════════════════════════════════════════════════${NC}"
        return 0
    else
        echo -e "\n${RED}══════════════════════════════════════════════════════════════${NC}"
        echo -e "${RED}✗ Failed to build${NC} ${BOLD}$description${NC}"
        echo -e "${RED}══════════════════════════════════════════════════════════════${NC}"
        return 1
    fi
}

# Build all variants
print_header "STARTING OPUS BUILDS"

# Build universal (both simulator and device)
run_build "build-libopus-arm.sh" "Universal (ARM) Build" || exit 1

# Build for real devices only
run_build "build-libopus-real.sh" "Real Devices Build" || exit 1

# Build for simulator only
run_build "build-libopus-sim.sh" "Simulator Build" || exit 1

# Print build summary
print_header "BUILD SUMMARY"

# Function to print library details
print_library_details() {
    local name=$1
    local path=$2
    echo -e "${BOLD}${YELLOW}$name:${NC}"
    echo -e "  ${CYAN}Path:${NC}         $path"
    echo -e "  ${CYAN}Size:${NC}         $(get_file_size "$path")"
    echo -e "  ${CYAN}Architectures:${NC} $(get_arch_info "$path")"
    echo -e "${BLUE}───────────────────────────────────────────────────────────────────────────${NC}"
}

echo -e "\n${BOLD}📊 Library Details${NC}\n"

print_library_details "Universal (ARM) Build" "dependencies-arm/lib/libopus.a"
print_library_details "Real Devices Build" "dependencies-real/lib/libopus.a"
print_library_details "Simulator Build" "dependencies-sim/lib/libopus.a"

# Verification summary
print_header "BUILD VERIFICATION SUMMARY"

# Function to verify build
verify_build() {
    local file=$1
    local expected_arch=$2
    local name=$3
    
    if [ -f "$file" ]; then
        local archs=$(get_arch_info "$file")
        if [[ $archs == *"$expected_arch"* ]]; then
            echo -e "${GREEN}✓${NC} $name: ${GREEN}Valid${NC} (Found expected architecture: $expected_arch)"
        else
            echo -e "${RED}✗${NC} $name: ${RED}Invalid${NC} (Expected $expected_arch, found: $archs)"
        fi
    else
        echo -e "${RED}✗${NC} $name: ${RED}File not found${NC}"
    fi
}

echo -e "\n${BOLD}🔍 Architecture Verification${NC}\n"
verify_build "dependencies-arm/lib/libopus.a" "arm64" "Universal (ARM) Build"
verify_build "dependencies-real/lib/libopus.a" "arm64" "Real Devices Build"
verify_build "dependencies-sim/lib/libopus.a" "arm64" "Simulator Build"

print_header "BUILD PROCESS COMPLETED"
echo -e "${GREEN}All builds completed successfully!${NC}\n"