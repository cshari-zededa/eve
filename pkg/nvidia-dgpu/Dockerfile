# syntax=docker/dockerfile-upstream:1.5.0-rc2-labs

# Copyright (c) 2026 Zededa, Inc.
# SPDX-License-Identifier: Apache-2.0
#
# NVIDIA dGPU Userspace Package for EVE OS
# Provides: nvidia-smi, CUDA 12 runtime, CUDA development tools, vectorAdd sample
# Architecture: amd64 only (desktop GPU - RTX 4000/5000/6000 series)
# Driver: NVIDIA 595 open kernel modules (already in kernel-ubuntu package)

FROM ubuntu:24.04 AS extract

WORKDIR /build

# Copy pre-downloaded .deb packages (hermetic build - no network access)
COPY debs/*.deb /build/debs/

# Extract all .deb packages into a staging directory
RUN mkdir -p /staging && \
    for deb in /build/debs/*.deb; do \
        echo "Extracting: $(basename $deb)" && \
        dpkg-deb -x "$deb" /staging/ ; \
    done

# Verify critical files exist
RUN test -f /staging/usr/bin/nvidia-smi && echo "nvidia-smi verified"
RUN ls /staging/usr/lib/x86_64-linux-gnu/libcuda.so* && echo "libcuda.so verified"
RUN ls /staging/usr/lib/x86_64-linux-gnu/libcudart.so* && echo "libcudart.so verified"
RUN test -f /staging/usr/bin/nvcc && echo "nvcc compiler verified"

# Create ld.so.conf.d entry for NVIDIA libraries
RUN mkdir -p /staging/etc/ld.so.conf.d && \
    echo "/usr/lib/x86_64-linux-gnu" > /staging/etc/ld.so.conf.d/nvidia-dgpu.conf && \
    echo "/usr/local/cuda/lib64" >> /staging/etc/ld.so.conf.d/nvidia-dgpu.conf

# Create convenience symlinks for CUDA
RUN mkdir -p /staging/usr/local/cuda/bin && \
    ln -sf /usr/include /staging/usr/local/cuda/include && \
    ln -sf /usr/lib/x86_64-linux-gnu /staging/usr/local/cuda/lib64 && \
    ln -sf /usr/bin/nvcc /staging/usr/local/cuda/bin/nvcc

# Copy pre-compiled vectorAdd binary (compiled on host with nvcc + g++-12)
COPY vectorAdd /staging/usr/local/bin/vectorAdd
RUN chmod +x /staging/usr/local/bin/vectorAdd

# Copy scripts into staging
RUN mkdir -p /staging/opt/nvidia-dgpu/init.d
COPY nv-dgpu-init.sh /staging/opt/nvidia-dgpu/init.d/nv-dgpu-init.sh
COPY nvidia-dgpu-wrapper.sh /staging/usr/bin/nvidia-dgpu-wrapper.sh
COPY nvidia-verify.sh /staging/usr/local/bin/nvidia-verify.sh
RUN chmod +x /staging/opt/nvidia-dgpu/init.d/nv-dgpu-init.sh \
             /staging/usr/bin/nvidia-dgpu-wrapper.sh \
             /staging/usr/local/bin/nvidia-verify.sh

# Generate ldconfig cache for staging
RUN ldconfig -r /staging 2>/dev/null || true

# Final image: Ubuntu 24.04 base with all NVIDIA userspace
# Ubuntu 24.04 already has libc6, libgcc-s1, libstdc++6 etc.
FROM ubuntu:24.04

# Copy all extracted NVIDIA packages and scripts
COPY --from=extract /staging/ /

# Run ldconfig to register NVIDIA libraries
RUN ldconfig

# Set up bash as default shell with proper prompt and tab completion
COPY bashrc /root/.bashrc
COPY profile /root/.profile
# Make /bin/sh point to bash so eve enter gets proper prompt and tab completion
RUN ln -sf /bin/bash /bin/sh

# Set environment
ENV PATH="/usr/local/cuda/bin:/usr/bin:/usr/local/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/usr/local/cuda/lib64"
ENV CUDA_HOME="/usr/local/cuda"

ENTRYPOINT []
CMD ["/usr/bin/nvidia-dgpu-wrapper.sh"]
