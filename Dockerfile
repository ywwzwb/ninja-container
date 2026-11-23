FROM alpine:latest AS builder
ARG TARGETARCH
# 上游 release 版本号（打 tag v1.0.8 时 CI 会自动传入 1.0.8）
ARG NINJA_VERSION=1.0.8
RUN apk add --no-cache dpkg wget
WORKDIR /tmp
RUN wget -q "https://github.com/kachetong1314/ninja/releases/download/${NINJA_VERSION}/ninjadesktop-lite_${NINJA_VERSION}_${TARGETARCH}.deb" -O app.deb && \
    mkdir -p extract && \
    dpkg-deb -x app.deb extract/ && \
    rm -f extract/opt/NinjaDesktopLite/ninja-service

FROM alpine:latest
ARG NINJA_VERSION=1.0.8
LABEL org.opencontainers.image.title="ninja-container" \
      org.opencontainers.image.description="NinjaDesktop Lite (headless) in a container" \
      org.opencontainers.image.version="${NINJA_VERSION}" \
      org.opencontainers.image.source="https://github.com/kachetong1314/ninja"
COPY --from=builder /tmp/extract/opt/NinjaDesktopLite/ninjadesktop-lite /usr/local/bin/ninjadesktop-lite
COPY --from=builder /tmp/extract/opt/NinjaDesktopLite/core/ /usr/local/bin/core/
RUN /usr/local/bin/ninjadesktop-lite config set listen 0.0.0.0
EXPOSE 9190 7897 7898 7899
VOLUME /etc/ninja
ENTRYPOINT ["/usr/local/bin/ninjadesktop-lite"]
