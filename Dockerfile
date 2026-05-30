# Stage 1 — builder
# Use the official Go image to compile the binary.
FROM golang:1.26-alpine AS builder

WORKDIR /app

# Copy dependency files first — Docker caches this layer.
# If go.mod and go.sum don't change, Docker skips go mod download
# on the next build. This makes builds significantly faster.
COPY go.mod ./
RUN go mod download

# Copy source and build.
# CGO_ENABLED=0 produces a statically linked binary —
# no external dependencies, runs in any Linux container.
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o hello-service .

# Stage 2 — final image
# scratch is an empty image — literally nothing installed.
# Only our binary goes in. No shell, no package manager, no vulnerabilities.
FROM scratch

WORKDIR /app

# Copy only the compiled binary from the builder stage.
COPY --from=builder /app/hello-service .

EXPOSE 8080

ENTRYPOINT ["./hello-service"]
