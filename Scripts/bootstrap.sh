#!/usr/bin/env bash

set -euo pipefail

# Declare globals
PROJECT_ROOT=$(git rev-parse --show-toplevel)
export PROJECT_ROOT
export SOURCES_PATH="$PROJECT_ROOT/Sources"
export SHARED_SOURCES_PATH="$SOURCES_PATH/Shared"
export IOS_SOURCES_PATH="$SOURCES_PATH/iOS"
export MACOS_SOURCES_PATH="$SOURCES_PATH/macOS"

# Create env.swift
env_file="$SHARED_SOURCES_PATH/env.swift"
cp "$SHARED_SOURCES_PATH/env.swift.example" "$env_file"
if [ -n "${SECRET_BUILDKITE_TOKEN}" ]; then
    sed -i "" -E 's/\{\{ SECRET_BUILDKITE_TOKEN \}\}/'"${SECRET_BUILDKITE_TOKEN}"'/' "$env_file"
else
    echo "*** SECRET_BUILDKITE_TOKEN was not defined. Please enter it yourself into $env_file"
fi
