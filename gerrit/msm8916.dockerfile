ARG DEB_RELEASE=buster
FROM debian:${DEB_RELEASE}

LABEL maintainer="Vincent Z"

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_VERSION_MAJOR=11

ENV GERRIT_HOME=/gerrit
ENV GERRIT_SITE=${GERRIT_HOME}/site

RUN apt update && \
        apt -y install --no-install-recommends \
                dumb-init \
                git \
                ssh \
                procps \
                bash \
                openjdk-${JAVA_VERSION_MAJOR}-jre-headless

RUN rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*deb

RUN useradd -d ${GERRIT_SITE} -r -s `which bash` gerrit && \
        update-alternatives --install /bin/sh sh `which bash` 10

COPY gerrit-init.sh /
RUN chmod +x /gerrit-init.sh

EXPOSE 8080/tcp
EXPOSE 29418/tcp

# change into dir where volume will be mounted
VOLUME [ "${GERRIT_HOME}" ] 

ENTRYPOINT [ "dumb-init" ]
CMD [ "sh", "-c", "/gerrit-init.sh" ]
