ARG VERSION
FROM docker.io/library/golang:1.23-alpine as builder

ARG VERSION
ARG TARGETOS
ARG TARGETARCH

ENV CGO_ENABLED=0 \
  GOOS=${TARGETOS} \
  GOARCH=${TARGETARCH}

WORKDIR /workspace

RUN apk add --no-cache git \
  && git clone -b "${VERSION}" https://github.com/backube/snapscheduler.git .

RUN go mod download

RUN go build -a -o manager -ldflags "-X=main.snapschedulerVersion=${VERSION}" ./cmd/main.go

FROM gcr.io/distroless/static:nonroot

WORKDIR /

COPY --from=builder /workspace/manager /manager

USER 65532:65532

ENTRYPOINT ["/manager"]
