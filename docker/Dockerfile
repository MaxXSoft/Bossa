FROM ubuntu:20.04

ARG GITHUB_PROXY
ARG BOSSA_HASH

# Install Git
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      git ca-certificates

# Clone Bossa
WORKDIR /root
RUN if [ -n "$GITHUB_PROXY" ]; then \
      git config --global url."$GITHUB_PROXY".insteadOf "https://github.com/" && \
      git config --global protocol.https.allow always; \
    fi
RUN git clone https://github.com/MaxXSoft/Bossa.git bossa && \
    cd bossa && \
    git checkout $BOSSA_HASH

# Setup prerequisites
WORKDIR /root/bossa
RUN ./scripts/setup-prerequisites.sh

# Initialize submodules
RUN git submodule update --init --recursive --depth=1

CMD ["/bin/bash"]
