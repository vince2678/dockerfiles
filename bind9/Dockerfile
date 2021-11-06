ARG DEB_RELEASE=bullseye
FROM debian:${DEB_RELEASE}

LABEL AUTHOR="Vincent Z."

RUN apt update && \
    apt -y install bind9 && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apt/archives/*deb

#COPY --chown=root:bind /etc/bind /etc/bind
#COPY --chown=bind:bind /var/cache/bind/keys /var/cache/bind/keys

# copy bind configuration
ADD bind9-config.tar /

RUN chown -R root:bind /etc/bind && \
    chown -R bind:bind /var/cache/bind

EXPOSE 53/tcp
EXPOSE 53/udp

ENTRYPOINT [ "named", "-f", "-u", "bind" ]