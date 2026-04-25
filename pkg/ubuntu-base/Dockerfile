# Ubuntu Base Package for EVE - Ultra Minimal
# This provides just the Ubuntu 24.04 base + helper script
# Individual packages will install their own dependencies

FROM ubuntu:24.04

ARG UBUNTU_VERSION=24.04
ENV DEBIAN_FRONTEND=noninteractive

# Only copy the helper script - no network access needed
COPY eve-ubuntu-deploy.sh /usr/bin/
RUN chmod +x /usr/bin/eve-ubuntu-deploy.sh

# Set environment
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH=/go  
ENV GOTOOLCHAIN=local

WORKDIR /
CMD ["/bin/bash"]
