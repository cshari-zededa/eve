# Ubuntu Base Package for EVE
# This replaces eve-alpine-base with Ubuntu 24.04

FROM ubuntu:24.04 AS base-build

ARG UBUNTU_VERSION=24.04
ARG TARGETARCH

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update and install essential build tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        gnupg \
        apt-utils \
        build-essential \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Copy helper scripts
COPY eve-ubuntu-deploy.sh /usr/bin/
RUN chmod +x /usr/bin/eve-ubuntu-deploy.sh

# Install Go (matching the version EVE uses)
ARG GO_VERSION=1.23.5
RUN arch=$(dpkg --print-architecture) && \
    curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${arch}.tar.gz" | \
    tar -C /usr/local -xzf -

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH=/go
ENV GOTOOLCHAIN=local

# Create directory structure
RUN mkdir -p /mirror/${UBUNTU_VERSION}/rootfs

# Stage 2: Architecture-specific builds
FROM base-build AS build-amd64
ARG TARGETARCH=amd64
ENV ZARCH=amd64

FROM base-build AS build-arm64  
ARG TARGETARCH=arm64
ENV ZARCH=arm64

FROM base-build AS build-riscv64
ARG TARGETARCH=riscv64
ENV ZARCH=riscv64

# Stage 3: Final image
FROM build-${TARGETARCH} AS final

# Set working directory
WORKDIR /

# Default shell
CMD ["/bin/bash"]
