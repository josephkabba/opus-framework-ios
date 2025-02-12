#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting Xcode project cleanup...${NC}"

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

# Function to check if Xcode is running and ask for confirmation
check_xcode_running() {
    if pgrep -x "Xcode" > /dev/null; then
        echo -e "${YELLOW}Warning: Xcode is currently running${NC}"
        read -p "Do you want to continue anyway? (y/n) " -n 1 -r
        echo    # Move to a new line
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${RED}Operation cancelled${NC}"
            exit 1
        fi
        echo -e "${YELLOW}Continuing with cleanup...${NC}"
    else
        echo -e "${GREEN}Xcode is not running. Proceeding with cleanup...${NC}"
    fi
}

# Check Xcode status and get confirmation if needed
check_xcode_running

echo -e "${YELLOW}1. Cleaning DerivedData...${NC}"
rm -rf ~/Library/Developer/Xcode/DerivedData/*
echo -e "${GREEN}DerivedData cleaned${NC}"

echo -e "${YELLOW}2. Removing Xcode user data and workspace...${NC}"
find . -name "xcuserdata" -type d -exec rm -rf {} +
find . -name "*.xcworkspace" -type d -exec rm -rf {} +
echo -e "${GREEN}Xcode user data removed${NC}"

echo -e "${YELLOW}3. Cleaning Pod cache (if Cocoapods is used)...${NC}"
if [ -f "Podfile" ]; then
    pod cache clean --all
    rm -rf Pods/
    rm -rf *.xcworkspace
    echo -e "${GREEN}Pod cache cleaned${NC}"
else
    echo -e "${YELLOW}No Podfile found - skipping Pod cache cleanup${NC}"
fi

echo -e "${YELLOW}4. Cleaning SPM cache (if SwiftPM is used)...${NC}"
rm -rf .build/
rm -rf *.xcodeproj/project.xcworkspace
echo -e "${GREEN}SPM cache cleaned${NC}"

echo -e "${GREEN}Cleanup complete!${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Reopen Xcode"
echo "2. Run 'pod install' (if using Cocoapods)"
echo "3. Build your project"