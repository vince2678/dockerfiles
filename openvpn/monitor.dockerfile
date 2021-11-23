ARG DEB_RELEASE=buster

FROM debian:${DEB_RELEASE}

LABEL maintainer="Vincent Z"
ENV DEBIAN_FRONTEND=noninteractive

RUN sed -i s'/ main/ main contrib non-free/'g /etc/apt/sources.list && \
     apt update && \
     apt-get -y --no-install-recommends install \
        dumb-init \
        git \
        python-geoip2 \
        python-ipaddr \
        python-humanize \
        python-bottle \
        python-semantic-version \
        gunicorn \
        geoip-database-extra \
        geoipupdate

WORKDIR /srv/

RUN git clone --depth=1 https://github.com/furlongm/openvpn-monitor && \
     rm -rf openvpn-monitor/.git

COPY openvpn-monitor.conf openvpn-monitor/

WORKDIR /srv/openvpn-monitor

RUN apt -y purge git && apt -y autoremove
RUN rm -rf /var/lib/dpkg/lists/* /var/cache/apt/archives/*deb

RUN useradd -d /srv/openvpn-monitor -M -r ovpn-monitor
RUN chown -R ovpn-monitor:ovpn-monitor .

EXPOSE 8080/tcp

ENTRYPOINT [ "dumb-init" ]
CMD [ "su", "ovpn-monitor", "-c", "gunicorn openvpn-monitor -b 0.0.0.0:8080" ]
