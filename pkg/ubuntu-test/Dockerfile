# Test Ubuntu-based EVE package
FROM lfedge/eve-ubuntu-base:421624a4660d8940907dba5f66e142a04fd54e6b AS build

# Install minimal packages needed for a test
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        coreutils \
    && rm -rf /var/lib/apt/lists/*

# Create a simple test script
RUN echo '#!/bin/bash' > /usr/bin/ubuntu-test && \
    echo 'echo "Ubuntu 24.04 package test successful!"' >> /usr/bin/ubuntu-test && \
    echo 'echo "Ubuntu version: $(cat /etc/os-release | grep PRETTY_NAME)"' >> /usr/bin/ubuntu-test && \
    echo 'echo "Kernel: $(uname -r)"' >> /usr/bin/ubuntu-test && \
    chmod +x /usr/bin/ubuntu-test

FROM scratch
COPY --from=build /usr/bin/ubuntu-test /usr/bin/
COPY --from=build /bin/bash /bin/
COPY --from=build /lib /lib
COPY --from=build /lib64 /lib64 2>/dev/null || true

CMD ["/usr/bin/ubuntu-test"]
