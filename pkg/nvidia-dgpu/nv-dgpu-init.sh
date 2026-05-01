#\!/bin/sh
# NVIDIA dGPU initialization script
# Runs at boot to load NVIDIA kernel modules and set up GPU devices
#
# Copyright (c) 2026 Zededa, Inc.
# SPDX-License-Identifier: Apache-2.0

echo "=== NVIDIA dGPU Init starting ==="

# Load NVIDIA open kernel modules (595)
# These are pre-built and included in the kernel-ubuntu package
for mod in nvidia nvidia-modeset nvidia-drm nvidia-uvm; do
    echo "Loading module: $mod"
    modprobe "$mod" 2>&1 || echo "WARNING: Failed to load $mod"
done

# Verify modules loaded
echo "--- Loaded NVIDIA modules ---"
lsmod | grep nvidia || echo "No NVIDIA modules loaded (expected in QEMU without GPU)"

# Create device nodes if they don exist
# On real hardware with GPU, udev handles this automatically
if [ -c /dev/nvidia0 ]; then
    echo "NVIDIA device nodes already exist"
else
    echo "No NVIDIA device nodes (expected without GPU hardware)"
fi

# Run ldconfig to register NVIDIA libraries
ldconfig 2>/dev/null || true

echo "=== NVIDIA dGPU Init complete ==="
