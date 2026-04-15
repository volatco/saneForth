# syntax=docker/dockerfile:1

FROM docker.io/library/golang:1.22-bookworm AS build
WORKDIR /src

# Cache module download first.
COPY tools/volatco-assist-go/go.mod ./tools/volatco-assist-go/go.mod
RUN --mount=type=cache,target=/go/pkg/mod \
    cd tools/volatco-assist-go && go mod download

# Build static Linux binary.
COPY tools/volatco-assist-go ./tools/volatco-assist-go
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    cd tools/volatco-assist-go && CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags='-s -w' -o /out/volatco-assist-go .

FROM docker.io/library/debian:bookworm-slim
WORKDIR /workspace

# ca-certificates is useful for future extensions; procps gives ps/top for debugging.
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates procps \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /out/volatco-assist-go /usr/local/bin/volatco-assist-go

# The app discovers repo root from cwd upward; mount the repo at /workspace.
ENTRYPOINT ["/usr/local/bin/volatco-assist-go"]
CMD ["--json"]
