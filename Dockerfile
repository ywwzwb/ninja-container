FROM alpine:latest AS builder
ARG TARGETARCH
RUN apk add --no-cache dpkg wget
WORKDIR /tmp
RUN wget -q "https://github.com/kachetong1314/ninja/releases/download/0.1.13/ninjadesktop-lite_0.1.13_${TARGETARCH}.deb" -O app.deb && \
    mkdir -p extract && \
    dpkg-deb -x app.deb extract/ && \
    rm -f extract/opt/NinjaDesktopLite/ninja-service

FROM alpine:latest
COPY --from=builder /tmp/extract/opt/NinjaDesktopLite/ninjadesktop-lite /usr/local/bin/ninjadesktop-lite
COPY --from=builder /tmp/extract/opt/NinjaDesktopLite/core/ /usr/local/bin/core/
RUN /usr/local/bin/ninjadesktop-lite config set listen 0.0.0.0
EXPOSE 9190 7897
VOLUME /etc/ninja
ENTRYPOINT ["/usr/local/bin/ninjadesktop-lite"]
