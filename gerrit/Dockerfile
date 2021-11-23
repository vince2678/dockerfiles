ARG DEB_RELEASE=stretch
FROM debian:${DEB_RELEASE}

LABEL maintainer="Vincent Z"

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_VERSION_MAJOR=8

ENV GERRIT_SITE=/gerrit
ENV GERRIT_UID 997
ENV GERRIT_GID 999

RUN apt update
RUN apt -y install --no-install-recommends \
        dumb-init \
	git \
	ssh \
	procps \
	bash \
        openjdk-${JAVA_VERSION_MAJOR}-jre-headless

RUN rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*deb

RUN groupadd -g $GERRIT_GID gerrit && \
	useradd -d ${GERRIT_SITE} -u $GERRIT_UID -g gerrit -s `which bash` gerrit && \
	update-alternatives --install /bin/sh sh `which bash` 10

WORKDIR ${GERRIT_SITE}

EXPOSE 8080/tcp
EXPOSE 29418/tcp

# change into dir where volume will be mounted
VOLUME [ "${GERRIT_SITE}" ] 

ENTRYPOINT [ "dumb-init" ]
CMD [ "su", "gerrit", "-c", "java -jar $GERRIT_SITE/bin/gerrit.war daemon --enable-httpd" ]
