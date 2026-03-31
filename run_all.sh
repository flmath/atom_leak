#!/bin/bash
set -e

# Try to find a container engine
if command -v docker >/dev/null 2>&1; then
    ENGINE="docker"
elif command -v podman >/dev/null 2>&1; then
    ENGINE="podman"
else
    echo "Neither 'docker' nor 'podman' found in PATH."
    exit 1
fi

echo "Using container engine: $ENGINE"

echo "Building container image..."
$ENGINE build -t atom-tester .

echo "Running tests in container..."
# Run container and capture output
$ENGINE run --rm atom-tester
