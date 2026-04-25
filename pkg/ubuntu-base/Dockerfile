# Ubuntu Base Package for EVE
# Simplified version focusing on essential tools only

FROM ubuntu:24.04 AS base

ARG UBUNTU_VERSION=24.04
ARG TARGETARCH

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Minimal setup - just copy the helper script
COPY eve-ubuntu-deploy.sh /usr/bin/
RUN chmod +x /usr/bin/eve-ubuntu-deploy.sh

# Install Go from binary (no apt needed for this)
ARG GO_VERSION=1.23.5
RUN arch=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/') && \
    mkdir -p /tmp/go && \
    cd /tmp/go && \
    wget -q "https://go.dev/dl/go${GO_VERSION}.linux-${arch}.tar.gz" && \
    tar -C /usr/local -xzf "go${GO_VERSION}.linux-${arch}.tar.gz" && \
    rm -rf /tmp/go

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH=/go
ENV GOTOOLCHAIN=local

WORKDIR /
CMD ["/bin/bash"]
