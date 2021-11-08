ARG DEB_RELEASE=bullseye

FROM debian:${DEB_RELEASE}

RUN apt update && \
    apt -y install \
     dumb-init \
     dante-server \
    && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apt/archives/*deb

COPY --chown=root:root danted.conf /etc/danted.conf

EXPOSE 1080/tcp
EXPOSE 1080/udp

ENTRYPOINT [ "dumb-init" ]
CMD [ "danted" ]