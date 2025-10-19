# Multi-stage Dockerfile for line-webhook
# Builder: use Alpine-based Go image for small size and speed
FROM golang:1.23-alpine AS builder

# Install necessary packages for fetching modules and building
RUN apk add --no-cache git build-base ca-certificates

WORKDIR /src

# Cache modules
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the sources
COPY . .

# Build a static, stripped binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags "-s -w" -o /line-webhook ./

# Runtime image: small Alpine with CA certs
FROM alpine:3.18
RUN apk add --no-cache ca-certificates

WORKDIR /
COPY --from=builder /line-webhook /line-webhook

EXPOSE 8080
ENV PORT=8080

ENTRYPOINT ["/line-webhook"]
