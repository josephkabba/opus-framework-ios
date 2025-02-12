#!/bin/bash

# 1. Tell Git to skip changes to these files locally
git update-index --skip-worktree DesklessWorkers/Common/Cells/GlobalFooterCell.xib
git update-index --skip-worktree DesklessWorkers.xcodeproj/project.pbxproj

# To revert this if needed later:
# git update-index --no-skip-worktree DesklessWorkers/Common/Cells/GlobalFooterCell.xib
# git update-index --no-skip-worktree DesklessWorkers.xcodeproj/project.pbxproj

# Check status of skip-worktree files
git ls-files -v | grep '^S'

# Additional helpful commands:
# List all skip-worktree files
git ls-files -v | grep '^S' | cut -c3-

# Create a bash function to easily see all skipped files:
function git-skipped {
    git ls-files -v | grep '^S' | cut -c3-
}

# Create functions to easily skip/unskip files:
function git-skip {
    git update-index --skip-worktree "$1"
}

function git-unskip {
    git update-index --no-skip-worktree "$1"
}