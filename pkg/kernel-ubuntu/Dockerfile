# Ubuntu 24.04 LTS Kernel for EVE
# Replaces Alpine kernel with Ubuntu 6.8.0 kernel

FROM ubuntu:24.04 AS extract

WORKDIR /kernel-build

# Copy pre-downloaded kernel files (to avoid network access in build)
COPY extracted/ /kernel-build/

# Run depmod to generate module dependencies
RUN depmod -b /kernel-build 6.8.0-110-generic || true

# Prepare kernel artifacts for LinuxKit format
RUN mkdir /out && \
    cp /kernel-build/boot/vmlinuz-6.8.0-110-generic /out/kernel && \
    cp /kernel-build/boot/config-6.8.0-110-generic /out/kernel_config && \
    cp /kernel-build/boot/System.map-6.8.0-110-generic /out/System.map && \
    tar cf /out/kernel.tar -C /kernel-build lib && \
    tar cf /out/kernel-dev.tar -C /kernel-build usr 2>/dev/null || true

FROM scratch
WORKDIR /
ENTRYPOINT []
CMD []
COPY --from=extract /out/* /
