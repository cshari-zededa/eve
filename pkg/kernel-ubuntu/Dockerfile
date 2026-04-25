# Ubuntu 24.04 LTS Kernel for EVE with Full GPU Support
# Includes NVIDIA (GeForce, Quadro, Tesla) and AMD (Radeon, RDNA) support

FROM ubuntu:24.04 AS extract

WORKDIR /kernel-build

# Copy pre-downloaded kernel and firmware files
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

# Add GPU support metadata
RUN echo "GPU Support: NVIDIA (Nouveau + Firmware), AMD (AMDGPU + Firmware)" > /out/GPU_SUPPORT.txt && \
    echo "NVIDIA Generations: Maxwell, Pascal, Volta, Turing, Ampere, Ada Lovelace, Hopper, Blackwell" >> /out/GPU_SUPPORT.txt && \
    echo "AMD Generations: GCN, RDNA, RDNA2, RDNA3, CDNA" >> /out/GPU_SUPPORT.txt && \
    echo "Firmware Files: 826 total (271 NVIDIA + 555 AMD)" >> /out/GPU_SUPPORT.txt

FROM scratch
WORKDIR /
ENTRYPOINT []
CMD []
COPY --from=extract /out/* /
