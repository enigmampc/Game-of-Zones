# Simple usage with a mounted data directory:
# > docker build -t gaia .
# > docker run -it -p 46657:46657 -p 46656:46656 -v ~/.enigmagozd:/root/.enigmagozd -v ~/.enigmagozcli:/root/.enigmagozcli gaia enigmagozd init
# > docker run -it -p 46657:46657 -p 46656:46656 -v ~/.enigmagozd:/root/.enigmagozd -v ~/.enigmagozcli:/root/.enigmagozcli gaia enigmagozd start
FROM golang:alpine AS build-env

# Set up dependencies
ENV PACKAGES curl make git libc-dev bash gcc linux-headers eudev-dev python

# Set working directory for the build
WORKDIR /go/src/github.com/enigmampc/Game-of-Zones

# Add source files
COPY . .

# Install minimum necessary dependencies, build Cosmos SDK, remove packages
RUN apk add --no-cache $PACKAGES && \
    make tools && \
    make install

# Final image
FROM alpine:edge

# Install ca-certificates
RUN apk add --update ca-certificates
WORKDIR /root

# Copy over binaries from the build-env
COPY --from=build-env /go/bin/enigmagozd /usr/bin/enigmagozd
COPY --from=build-env /go/bin/enigmagozcli /usr/bin/enigmagozcli

# Run enigmagozd by default, omit entrypoint to ease using container with enigmagozcli
CMD ["enigmagozd"]
