FROM scratch

SHELL [ "/bin/bash", "-c" ]

# a custom bullseye image is needed to install
# windscribe without any errors.
ADD bullseye.tgz /

ENV WS_PIDFILE=/etc/windscribe/windscribe.pid
ENV WS_WRAPPER=/root/windscribe-wrapper.sh

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key FDC247B7 && \
    echo 'deb https://repo.windscribe.com/debian buster main' > /etc/apt/sources.list.d/windscribe-repo.list && \
    apt update

RUN apt -y --no-install-recommends install \
        dante-server \
        windscribe-cli \
    && apt -yf --no-install-recommends install

RUN rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apt/archives/*deb

COPY --chown=root:root danted.conf /etc/danted.conf
COPY windscribe-wrapper.sh ${WS_WRAPPER}

RUN chmod +x ${WS_WRAPPER}

RUN rm -f ${WS_PIDFILE}

VOLUME [ "/etc/windscribe" ]

EXPOSE 1080/tcp
EXPOSE 1080/udp

ENTRYPOINT [ "dumb-init" ]
CMD [ "sh", "-c", "${WS_WRAPPER} start && danted" ]
