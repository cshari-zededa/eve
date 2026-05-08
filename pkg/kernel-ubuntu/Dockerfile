# Ubuntu 24.04 LTS Kernel for EVE - AMD64 with NVIDIA 595 Open GPU Modules
# Kernel: 6.8.0-111-generic (x86_64) - Custom compiled with NVMe/AHCI/OverlayFS built-in
# NVIDIA modules built against custom kernel build tree for matching struct module size
# Includes: nouveau blacklist, NVIDIA open kernel modules (595), firmware

FROM ubuntu:24.04 AS extract

WORKDIR /kernel-build

# Copy pre-downloaded kernel, modules, firmware, and NVIDIA open modules
# modules.dep was pre-generated on the host using: depmod -a -b extracted/ 6.8.0-111-generic
# nvidia modules built against custom kernel at /tmp/kernel-build/linux-source-6.8.0
COPY extracted/ /kernel-build/

# Verify modules.dep exists
RUN test -f /kernel-build/lib/modules/6.8.0-111-generic/modules.dep && \
    ls -lh /kernel-build/lib/modules/6.8.0-111-generic/modules.dep* && \
    echo "modules.dep verified (pre-generated)"

# Verify NVIDIA 595 open modules exist (built against custom kernel)
RUN test -f /kernel-build/lib/modules/6.8.0-111-generic/kernel/nvidia-595-open/nvidia.ko && \
    echo "NVIDIA 595 open kernel modules verified"

# Verify NVIDIA GSP firmware (required for RTX 5080 / Blackwell)
RUN test -f /kernel-build/lib/firmware/nvidia/595.58.03/gsp_ga10x.bin && \
    test -f /kernel-build/lib/firmware/nvidia/595.58.03/gsp_tu10x.bin && \
    echo "NVIDIA GSP firmware verified (595.58.03)"

# Verify nouveau blacklist
RUN test -f /kernel-build/etc/modprobe.d/blacklist-nouveau.conf && \
    echo "nouveau blacklist verified"

# Verify key WiFi drivers
RUN (test -f /kernel-build/lib/modules/6.8.0-111-generic/kernel/drivers/net/wireless/mediatek/mt76/mt7921/mt7921e.ko || \
     test -f /kernel-build/lib/modules/6.8.0-111-generic/kernel/drivers/net/wireless/mediatek/mt76/mt7921/mt7921e.ko.zst) && \
    echo "MT7922 WiFi driver verified"

# Prepare kernel artifacts for LinuxKit format
# Include both lib/ (modules+firmware) and etc/ (modprobe.d blacklist)
RUN mkdir /out && \
    cp /kernel-build/boot/vmlinuz-6.8.0-111-generic /out/kernel && \
    cp /kernel-build/boot/config-6.8.0-111-generic /out/kernel_config && \
    cp /kernel-build/boot/System.map-6.8.0-111-generic /out/System.map && \
    tar cf /out/kernel.tar -C /kernel-build lib etc && \
    tar cf /out/kernel-dev.tar -C /kernel-build usr 2>/dev/null || true

FROM scratch
WORKDIR /
ENTRYPOINT []
CMD []
COPY --from=extract /out/* /
