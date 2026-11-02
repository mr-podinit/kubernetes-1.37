FROM golang:1.27-trixie AS containerd-builder

ARG CONTAINERD_REPO=https://github.com/nispriha/containerd.git
ARG CONTAINERD_BRANCH=njagan/mount-options-support
ARG TARGETOS=linux
ARG TARGETARCH=amd64

RUN apt-get update && apt-get install -y --no-install-recommends \
        git make btrfs-progs libbtrfs-dev libseccomp-dev \
        pkg-config gcc \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

RUN git clone --depth 1 --branch "${CONTAINERD_BRANCH}" "${CONTAINERD_REPO}" .

# Cross-compile per la architettura target del nodo Kind
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} CGO_ENABLED=0 make binaries \
    && ls -la bin/

FROM kindest/node:v1.37.0

# Copia i binari containerd custom (percorsi standard containerd)
COPY --from=containerd-builder /src/bin/containerd              /usr/local/bin/containerd
COPY --from=containerd-builder /src/bin/ctr                       /usr/local/bin/ctr

RUN chmod +x /usr/local/bin/containerd* /usr/local/bin/ctr

ENTRYPOINT ["/usr/local/bin/entrypoint", "/sbin/init"]