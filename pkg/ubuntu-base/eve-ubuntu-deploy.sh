#!/bin/sh
# shellcheck disable=SC2086
# shellcheck disable=SC2154
#
# This script is used to setup Ubuntu build environments
# for EVE containers and produce the resulting, Ubuntu-based
# executable container if needed.
#
# This script is driven by the following environment variables:
#   BUILD_PKGS - packages required for the build stage
#   BUILD_PKGS_[amd64|arm64|riscv64] - like BUILD_PKGS but arch specific
#   PKGS - packages required for the executable container
#   PKGS_[amd64|arm64|riscv64] - like PKGS but arch specific
#
set -e

UBUNTU_VERSION=${1:-24.04}

bail() {
   echo "$@"
   exit 1
}

case "$(uname -m)" in
   x86_64) BUILD_PKGS="$BUILD_PKGS $BUILD_PKGS_amd64"
           PKGS="$PKGS $PKGS_amd64"
           ;;
  aarch64) BUILD_PKGS="$BUILD_PKGS $BUILD_PKGS_arm64"
           PKGS="$PKGS $PKGS_arm64"
           ;;
  riscv64) BUILD_PKGS="$BUILD_PKGS $BUILD_PKGS_riscv64"
           PKGS="$PKGS $PKGS_riscv64"
           ;;
esac

# Update package lists
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq

# Install build packages if specified
set $BUILD_PKGS
if [ $# -gt 0 ]; then
    apt-get install -y --no-install-recommends "$@"
fi

# Create output directory with minimal Ubuntu base
rm -rf /out
mkdir /out

# Copy essential Ubuntu base files
for dir in etc usr lib bin sbin var; do
    if [ -d "/$dir" ]; then
        mkdir -p /out/$dir
    fi
done

# Install runtime packages into /out
set $PKGS
if [ $# -gt 0 ]; then
    # Create a minimal chroot environment
    apt-get install -y --no-install-recommends \
        --root=/out \
        -o APT::Install-Recommends=false \
        -o APT::Install-Suggests=false \
        "$@" || \
    # Fallback: install to host then copy
    (apt-get install -y --no-install-recommends "$@" && \
     dpkg --root=/out -i $(dpkg -L $@ | grep "\.deb$"))
fi

# Clean up
apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /out/var/lib/apt/lists/* /out/tmp/* /out/var/tmp/* 2>/dev/null || true

echo "Ubuntu deployment complete"
