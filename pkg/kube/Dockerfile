# syntax=docker/dockerfile-upstream:1.5.0-rc2-labs

# Build stage: Alpine (for Go compilation)
FROM lfedge/eve-alpine:1f744180283ffb4eabcc3862531aeacf1de886b3 AS build
ENV PKGS alpine-baselayout musl-utils
RUN eve-alpine-deploy.sh

COPY eve-bridge /plugins/eve-bridge
WORKDIR /plugins/eve-bridge
RUN GO111MODULE=on CGO_ENABLED=0 go build -v -ldflags "-s -w" -mod=vendor -o /usr/bin/eve-bridge .

COPY cert-gen /plugins/cert-gen
WORKDIR /plugins/cert-gen
RUN GO111MODULE=on CGO_ENABLED=0 go build -v -ldflags "-s -w" -o /usr/bin/cert-gen .

COPY update-component /plugins/update-component
WORKDIR /plugins/update-component
RUN GO111MODULE=on go build -v -ldflags "-s -w" -mod=vendor -o /usr/bin/update-component .

# Runtime stage: Ubuntu 24.04
FROM ubuntu:24.04

# Copy ALL .deb packages with dependencies (163 files)
COPY ubuntu-packages-full/*.deb /tmp/debs/

# Install packages in multiple passes to resolve dependencies
RUN cd /tmp/debs && \
    dpkg -i *.deb 2>&1 || true && \
    dpkg --configure -a 2>&1 || true && \
    dpkg -i --force-depends *.deb 2>&1 || true && \
    dpkg --configure -a 2>&1 && \
    rm -rf /tmp/debs

# Set bash as default shell and configure prompt
RUN ln -sf /bin/bash /bin/sh && \
    echo 'export PS1="[kube] \\u@\\h:\\w\\$ "' >> /etc/profile && \
    echo 'export PS1="[kube] \\u@\\h:\\w\\$ "' >> /etc/bash.bashrc

# Disable IPv6 to fix DNS resolution in QEMU user-mode networking
# QEMU returns IPv6 addresses via DNS but does not route IPv6 traffic,
# causing apt and other tools to timeout when trying to connect
RUN echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf && \
    echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf

# Copy Go binaries from build stage (changed from /out/ / to specific binaries)
COPY --from=build /usr/bin/eve-bridge /usr/bin/eve-bridge
COPY --from=build /usr/bin/cert-gen /usr/bin/cert-gen
COPY --from=build /usr/bin/update-component /usr/bin/update-component

# Mirror the Alpine Dockerfile structure from here...

RUN mkdir -p /usr/bin/kube/
RUN mkdir -p /etc/kube/
COPY cluster-init.sh /usr/bin/
COPY cluster-utils.sh /usr/bin/
COPY cgconfig.conf /etc
COPY utils.sh /usr/bin/
COPY pubsub.sh /usr/bin/
COPY tie-breaker-utils.sh /usr/bin/
COPY lib/* /usr/bin/
RUN mkdir -p /etc/k3s-manifests
COPY manifests/* /etc/k3s-manifests/

# upgrades
COPY cluster-update.sh /usr/bin/
COPY update-component/expected_versions.yaml /etc/
RUN chmod +x /usr/bin/*.sh
COPY update-component/settings_longhorn.yaml /etc/

# k3s
COPY install-etcdctl.sh /usr/bin/
RUN mkdir -p /etc/rancher/k3s
COPY config.yaml /etc/rancher/k3s
COPY debuguser-role-binding.yaml /etc/
COPY k3s-pod-logs.sh /usr/bin/
COPY registration-utils.sh /usr/bin/
COPY all-kube-events.sh /usr/bin/
COPY lib/* /usr/bin/kube/
COPY cfg-manifests/03-enc-disable-local-path.yaml /etc/kube/

# kubevirt yaml files
COPY multus-daemonset.yaml /etc
COPY kubevirt-operator.yaml /etc
COPY kubevirt-features.yaml /etc
COPY external-boot-image.tar /etc/
COPY kubevirt-utils.sh /usr/bin/
COPY vnc-proxy.sh /usr/bin/

# Longhorn config
COPY longhorn-utils.sh /usr/bin/
COPY lh-cfg-v1.9.1.yaml /etc/
COPY iscsid.conf /etc/iscsi/
COPY longhorn-generate-support-bundle.sh /usr/bin/
COPY nsmounter /usr/bin/
COPY longhorn_uninstall_settings.yaml /etc/
COPY failover-events.sh /usr/bin/
COPY cfg-manifests/longhorn-cfg.yaml /etc/

# descheduler
COPY descheduler-utils.sh /usr/bin/
COPY descheduler_rbac.yaml /etc/
COPY descheduler-job.yaml /etc/
COPY descheduler-policy-configmap.yaml /etc/

# ACE
COPY kube-api-authn-webhook.yaml /etc

# Containerd config
RUN mkdir -p /etc/containerd
COPY config-k3s.toml /etc/containerd/
WORKDIR /

# Kube-VIP
COPY kubevip-sa.yaml /etc/
COPY kubevip-ds.yaml /etc/
COPY kubevip-apply.sh /usr/bin/
COPY kubevip-delete.sh /usr/bin/
RUN chmod +x /usr/bin/kubevip-apply.sh /usr/bin/kubevip-delete.sh

# nvidia-container-runtime config
RUN mkdir -p /etc/nvidia-container-runtime
COPY nvidia-container-runtime/config.toml /etc/nvidia-container-runtime
COPY nvidia-container-runtime/nvidia-device-plugin-18.0.yml /etc/k3s-manifests/

ARG TARGETARCH

# k3s control scripts
COPY k3s-control.sh /usr/bin/k3s-control
RUN chmod +x /usr/bin/k3s-control && \
    ln -s /usr/bin/k3s-control /usr/bin/k3s-stop && \
    ln -s /usr/bin/k3s-control /usr/bin/k3s-start && \
    ln -s /usr/bin/k3s-control /usr/bin/k3s-status

ENV VIRTCTL_VERSION v1.6.0
ADD https://github.com/kubevirt/kubevirt/releases/download/${VIRTCTL_VERSION}/virtctl-${VIRTCTL_VERSION}-linux-${TARGETARCH} .

RUN install virtctl-${VIRTCTL_VERSION}-linux-${TARGETARCH} /usr/bin/virtctl
RUN rm -f ./virtctl-${VIRTCTL_VERSION}-linux-${TARGETARCH}

ENTRYPOINT []
CMD ["/usr/bin/cluster-init.sh"]
