# Build the manager binary
FROM golang:1.17 as builder

WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
RUN go mod download

# Copy the go source
COPY main.go main.go

# Build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o multiarch-test main.go

FROM registry.access.redhat.com/ubi8/ubi-micro
WORKDIR /
COPY --from=builder /workspace/multiarch-test .
USER 65532:65532

ENTRYPOINT ["/multiarch-test"]
