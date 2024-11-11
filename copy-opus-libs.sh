#!/bin/bash

# Set bash to exit on first error
set -e

# Get current directory
CURRENT_DIR=$(pwd)

# Define dependency paths
DEPS_ARM="${CURRENT_DIR}/dependencies-arm"
DEPS_REAL="${CURRENT_DIR}/dependencies-real"
DEPS_SIM="${CURRENT_DIR}/dependencies-sim"
IOS_DEPS_PATH="$HOME/Documents/work/heytung/iOS-app/dependencies"

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Initialize flags
COPY_ARM=false
COPY_REAL=false
COPY_SIM=false

# Print header function
print_header() {
    echo -e "\n${BOLD}${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${BLUE}   $1${NC}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}\n"
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

# Function to show usage
show_usage() {
    echo -e "${CYAN}Usage:${NC} $0 [OPTIONS]"
    echo -e "\n${CYAN}Options:${NC}"
    echo -e "  --arm     Copy universal (ARM) build"
    echo -e "  --real    Copy real device build"
    echo -e "  --sim     Copy simulator build"
    echo -e "  --help    Show this help message"
    echo -e "\n${CYAN}Example:${NC}"
    echo -e "  $0 --arm              # Copy only ARM build"
    echo -e "  $0 --real --sim       # Copy both real and simulator builds"
    echo -e "  $0 --arm --real --sim # Copy all builds"
    exit 1
}

# Function to copy and verify a specific build
copy_build() {
    local source_dir=$1
    local build_name=$2
    
    echo -e "\n${CYAN}Copying${NC} ${YELLOW}$build_name${NC} ${CYAN}build...${NC}"
    
    # Check source exists
    if [ ! -d "$source_dir" ]; then
        echo -e "${RED}Error: Source directory $source_dir does not exist${NC}"
        echo -e "${YELLOW}Please run the build script first${NC}"
        return 1
    fi

    # Check source library exists
    if [ ! -f "$source_dir/lib/libopus.a" ]; then
        echo -e "${RED}Error: Source library $source_dir/lib/libopus.a does not exist${NC}"
        echo -e "${YELLOW}Please run the build script first${NC}"
        return 1
    fi

    # Create destination if it doesn't exist
    if [ ! -d "$IOS_DEPS_PATH" ]; then
        echo -e "${YELLOW}Creating destination directory...${NC}"
        mkdir -p "$IOS_DEPS_PATH"
    fi

    # Copy files
    if cp -R "$source_dir/"* "$IOS_DEPS_PATH/"; then
        echo -e "${GREEN}✓ Successfully copied $build_name build${NC}"
        
        echo -e "\n${CYAN}Verifying $build_name build:${NC}"
        echo -e "  ${CYAN}Size:${NC}         $(get_file_size "$IOS_DEPS_PATH/lib/libopus.a")"
        echo -e "  ${CYAN}Architectures:${NC} $(get_arch_info "$IOS_DEPS_PATH/lib/libopus.a")"
        
        # Verify sizes match
        local SRC_SIZE=$(get_file_size "$source_dir/lib/libopus.a")
        local DEST_SIZE=$(get_file_size "$IOS_DEPS_PATH/lib/libopus.a")
        if [ "$SRC_SIZE" = "$DEST_SIZE" ]; then
            echo -e "  ${GREEN}✓ File sizes match${NC}"
        else
            echo -e "  ${RED}✗ File sizes do not match${NC}"
            return 1
        fi
        
        return 0
    else
        echo -e "${RED}✗ Failed to copy $build_name build${NC}"
        return 1
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --arm)
            COPY_ARM=true
            shift
            ;;
        --real)
            COPY_REAL=true
            shift
            ;;
        --sim)
            COPY_SIM=true
            shift
            ;;
        --help)
            show_usage
            ;;
        *)
            echo -e "${RED}Error: Unknown option $1${NC}"
            show_usage
            ;;
    esac
done

# Check if at least one option was selected
if ! $COPY_ARM && ! $COPY_REAL && ! $COPY_SIM; then
    echo -e "${RED}Error: No build type selected${NC}"
    show_usage
fi

print_header "COPYING OPUS LIBRARIES TO IOS PROJECT"

# Counter for successful copies
SUCCESSFUL_COPIES=0

# Copy selected builds
if $COPY_ARM; then
    copy_build "$DEPS_ARM" "Universal (ARM)" && ((SUCCESSFUL_COPIES++))
fi

if $COPY_REAL; then
    copy_build "$DEPS_REAL" "Real Device" && ((SUCCESSFUL_COPIES++))
fi

if $COPY_SIM; then
    copy_build "$DEPS_SIM" "Simulator" && ((SUCCESSFUL_COPIES++))
fi

print_header "COPY PROCESS COMPLETED"
echo -e "${GREEN}Successfully copied $SUCCESSFUL_COPIES selected builds!${NC}\n"