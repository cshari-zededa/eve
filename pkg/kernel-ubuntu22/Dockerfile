# Ubuntu 22.04 LTS Kernel for EVE
# Kernel 5.15.0-176-generic with full module support

FROM ubuntu:22.04 AS extract

WORKDIR /kernel-build

# Copy pre-downloaded kernel, modules with pre-generated modules.dep
COPY extracted/ /kernel-build/

# Verify modules.dep exists
RUN test -f /kernel-build/lib/modules/5.15.0-176-generic/modules.dep && \
    ls -lh /kernel-build/lib/modules/5.15.0-176-generic/modules.dep* && \
    echo "✅ modules.dep verified (pre-generated)"

# Prepare kernel artifacts for LinuxKit format
RUN mkdir /out && \
    cp /kernel-build/boot/vmlinuz-5.15.0-176-generic /out/kernel && \
    cp /kernel-build/boot/config-5.15.0-176-generic /out/kernel_config && \
    cp /kernel-build/boot/System.map-5.15.0-176-generic /out/System.map && \
    tar cf /out/kernel.tar -C /kernel-build lib && \
    tar cf /out/kernel-dev.tar -C /kernel-build usr 2>/dev/null || true

# Add kernel metadata
RUN echo "Ubuntu 22.04 LTS Kernel: 5.15.0-176-generic" > /out/KERNEL_VERSION.txt && \
    echo "Build Date: $(date)" >> /out/KERNEL_VERSION.txt && \
    echo "Total Modules: $(find /kernel-build/lib/modules -name \"*.ko\" | wc -l)" >> /out/KERNEL_VERSION.txt

FROM scratch
WORKDIR /
ENTRYPOINT []
CMD []
COPY --from=extract /out/* /
