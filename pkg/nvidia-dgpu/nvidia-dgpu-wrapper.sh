#!/bin/sh
# NVIDIA dGPU service wrapper
# Keeps container alive so it can be accessed via "eve enter nvidia-dgpu"
#
# Copyright (c) 2026 Zededa, Inc.
# SPDX-License-Identifier: Apache-2.0

echo "========================================"
echo " NVIDIA dGPU Container (EVE OS)"
echo "========================================"
echo " Driver: NVIDIA 595 Open Kernel Modules"
echo " CUDA:   12.0 (Ubuntu 24.04)"
echo " GPU:    RTX 4000/5000/6000 series"
echo "========================================"
echo ""
echo "Available commands:"
echo "  nvidia-smi          - GPU status and info"
echo "  nvcc --version      - CUDA compiler version"
echo "  vectorAdd           - CUDA sample program"
echo "  nvidia-verify.sh    - Full verification"
echo ""
echo "Access via: eve enter nvidia-dgpu"
echo "========================================"

# Run init script to load modules
/opt/nvidia-dgpu/init.d/nv-dgpu-init.sh 2>&1

# Keep container alive
exec tail -f /dev/null
