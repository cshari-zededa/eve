#!/bin/sh
# Minimal cluster-init.sh for testing k3s installation
# Version 9 - Fixed DNS, download retry, containerd-user symlink, stay-alive
# Backported from working device (10.0.0.69) to build VM

set -x  # Debug mode

LOGFILE="/persist/kubelog/k3s-install.log"
mkdir -p /persist/kubelog
exec >> "$LOGFILE" 2>&1

echo "=== Minimal cluster-init.sh v9 starting at $(date) ==="
echo "Architecture: $(uname -m)"

# Step 1: Fix DNS - CRITICAL for downloading k3s
# MUST be unconditional - EVE kube container often starts with empty resolv.conf
echo "=== Step 1: Setting up DNS ==="
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf
cat /etc/resolv.conf

# Disable IPv6 immediately
sysctl -w net.ipv6.conf.all.disable_ipv6=1 || true
sysctl -w net.ipv6.conf.default.disable_ipv6=1 || true
sysctl -w net.ipv6.conf.lo.disable_ipv6=1 || true

# Step 2: Basic setup
echo "=== Step 2: Basic directory setup ==="
mkdir -p /var/log /var/lib/rancher/k3s/server /etc/rancher/k3s
mkdir -p /var/lib/rancher/k3s/agent/etc/containerd

# Create containerd config to use overlayfs snapshotter
cat > /var/lib/rancher/k3s/agent/etc/containerd/config.toml <<EOFCONTAINERD
[plugins."io.containerd.grpc.v1.cri".containerd]
  snapshotter = "overlayfs"
  disable_snapshot_annotations = true
EOFCONTAINERD

# Symlink log directory
ln -sf /persist/kubelog /var/log

# k3s config
cat > /etc/rancher/k3s/config.yaml <<EOFCONFIG
write-kubeconfig-mode: "0644"
disable:
  - traefik
  - servicelb
snapshotter: overlayfs
EOFCONFIG

# Step 3: Download k3s binary
echo "=== Step 3: Download k3s ==="
K3S_VERSION="v1.34.2+k3s1"
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    K3S_BINARY="k3s"
elif [ "$ARCH" = "aarch64" ]; then
    K3S_BINARY="k3s-arm64"
else
    K3S_BINARY="k3s"
fi

K3S_URL="https://github.com/k3s-io/k3s/releases/download/${K3S_VERSION}/${K3S_BINARY}"

# Check if k3s binary already exists and is executable
if [ -x /usr/local/bin/k3s ]; then
    echo "k3s binary already exists at /usr/local/bin/k3s, skipping download"
    ls -la /usr/local/bin/k3s
else
    echo "Downloading k3s ${K3S_VERSION} (binary: ${K3S_BINARY}) for ${ARCH}..."

    # Retry download up to 5 times with increasing delay
    DOWNLOAD_OK=0
    for attempt in 1 2 3 4 5; do
        echo "Download attempt ${attempt}/5..."
        if curl -fL --connect-timeout 30 --max-time 300 -o /usr/local/bin/k3s "${K3S_URL}"; then
            chmod +x /usr/local/bin/k3s
            echo "Download successful on attempt ${attempt}"
            DOWNLOAD_OK=1
            break
        else
            echo "Download failed on attempt ${attempt}, waiting ${attempt}0 seconds..."
            sleep $((attempt * 10))
        fi
    done

    if [ "$DOWNLOAD_OK" != "1" ]; then
        echo "ERROR: Failed to download k3s after 5 attempts"
        echo "Will keep container alive for manual intervention"
        echo "You can manually download with: eve enter kube"
        exec tail -f /dev/null
    fi
fi

echo "k3s binary:"
ls -la /usr/local/bin/k3s
/usr/local/bin/k3s --version || true

# Create symlinks
ln -sf /usr/local/bin/k3s /usr/local/bin/kubectl
ln -sf /usr/local/bin/k3s /usr/local/bin/crictl

# Step 4: Create containerd-user directory for EVE pillar compatibility
echo "=== Step 4: Create containerd-user directory ==="
mkdir -p /run/containerd-user
# k3s will create its containerd socket at /run/k3s/containerd/containerd.sock
# EVE pillar expects it at /run/containerd-user/containerd.sock
# We create the symlink after k3s starts its containerd below

# Step 5: Start k3s server
echo "=== Step 5: Starting k3s server ==="
echo "Starting at $(date)"

# Run k3s in the background
/usr/local/bin/k3s server \
    --snapshotter=overlayfs \
    --write-kubeconfig-mode=0644 \
    --disable=traefik,servicelb \
    --data-dir=/persist/kube/k3s \
    --kubelet-arg="--root-dir=/persist/kube/kubelet" \
    --log=/persist/kubelog/k3s-server.log &

K3S_PID=$!
echo "k3s server started with PID: ${K3S_PID}"

# Wait for k3s containerd socket to appear, then create symlink
echo "=== Waiting for k3s containerd socket ==="
SOCKET_WAIT=0
while [ ! -S /run/k3s/containerd/containerd.sock ] && [ $SOCKET_WAIT -lt 120 ]; do
    sleep 2
    SOCKET_WAIT=$((SOCKET_WAIT + 2))
    echo "Waiting for containerd socket... (${SOCKET_WAIT}s)"
done

if [ -S /run/k3s/containerd/containerd.sock ]; then
    ln -sf /run/k3s/containerd/containerd.sock /run/containerd-user/containerd.sock
    echo "containerd-user symlink created successfully"
    ls -la /run/containerd-user/containerd.sock
else
    echo "WARNING: containerd socket not found after ${SOCKET_WAIT}s"
fi

# Wait for k3s to be ready
echo "=== Waiting for k3s to be ready ==="
READY_WAIT=0
while [ $READY_WAIT -lt 180 ]; do
    if /usr/local/bin/k3s kubectl get nodes 2>/dev/null | grep -q "Ready"; then
        echo "k3s is ready!"
        /usr/local/bin/k3s kubectl get nodes
        /usr/local/bin/k3s kubectl get pods -A
        break
    fi
    sleep 5
    READY_WAIT=$((READY_WAIT + 5))
    echo "Waiting for k3s ready... (${READY_WAIT}s)"
done

echo "=== cluster-init.sh v9 setup complete at $(date) ==="
echo "k3s PID: ${K3S_PID}"
echo "Keeping container alive..."

# Keep the container alive by waiting on k3s
wait ${K3S_PID}

# If k3s exits, keep container alive for debugging
echo "WARNING: k3s exited at $(date)"
exec tail -f /dev/null
