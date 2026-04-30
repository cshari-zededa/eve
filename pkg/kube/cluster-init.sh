#!/bin/sh
# Minimal cluster-init.sh for testing k3s installation
# Version 5 - Fixed containerd directory creation

set -x  # Debug mode

LOGFILE="/persist/kubelog/k3s-install.log"
mkdir -p /persist/kubelog
exec >> "$LOGFILE" 2>&1

echo "=== Minimal cluster-init.sh v5 starting at $(date) ==="

# Disable IPv6 immediately
sysctl -w net.ipv6.conf.all.disable_ipv6=1 || true
sysctl -w net.ipv6.conf.default.disable_ipv6=1 || true
sysctl -w net.ipv6.conf.lo.disable_ipv6=1 || true

# Basic setup
mkdir -p /var/log /var/lib/rancher/k3s/server /etc/rancher/k3s
mkdir -p /var/lib/rancher/k3s/agent/etc/containerd

# Create containerd config to use native snapshotter (fixes overlayfs nesting issue)
cat > /var/lib/rancher/k3s/agent/etc/containerd/config.toml <<EOFCONTAINERD
[plugins."io.containerd.grpc.v1.cri".containerd]
  snapshotter = "native"
  disable_snapshot_annotations = true
EOFCONTAINERD

ln -sf /persist/kubelog /var/log

# Create k3s config - use native snapshotter instead of overlayfs
cat > /etc/rancher/k3s/config.yaml <<EOFCONFIG
write-kubeconfig-mode: "0644"
cluster-init: true
snapshotter: native
disable:
  - servicelb
  - traefik
EOFCONFIG

# Download k3s
K3S_VERSION="v1.34.2+k3s1"
K3S_URL="https://github.com/k3s-io/k3s/releases/download/${K3S_VERSION}/k3s-arm64"

echo "Downloading k3s ${K3S_VERSION}..."
curl -sfL -o /usr/local/bin/k3s "$K3S_URL" || {
    echo "ERROR: Failed to download k3s"
    exit 1
}
chmod +x /usr/local/bin/k3s

# Create symlinks
ln -sf /usr/local/bin/k3s /usr/local/bin/kubectl
ln -sf /usr/local/bin/k3s /usr/local/bin/crictl

# Verify
echo "=== k3s binary installed ==="
/usr/local/bin/k3s --version

# Start k3s with native snapshotter
echo "Starting k3s server with native snapshotter..."
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
nohup /usr/local/bin/k3s server --snapshotter=native >> "$LOGFILE" 2>&1 &

# Wait for k3s to be ready
echo "Waiting for k3s to be ready..."
for i in $(seq 1 120); do
    if /usr/local/bin/kubectl get nodes 2>/dev/null | grep -q Ready; then
        echo "=== SUCCESS: k3s is Ready! ==="
        break
    fi
    echo "Waiting... ($i/120)"
    sleep 5
done

# Show status
echo "=== k3s node status ==="
/usr/local/bin/kubectl get nodes
echo "=== k3s pods status ==="
/usr/local/bin/kubectl get pods -A
echo "=== Minimal cluster-init.sh v5 complete ==="

# Keep running
tail -f /dev/null
