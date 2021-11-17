ARG DEB_RELEASE=bullseye
FROM debian:${DEB_RELEASE} as spigot-builder

ENV CONTAINER_WORKDIR=/spigotmc/
WORKDIR ${CONTAINER_WORKDIR}/out/

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_VERSION_MAJOR=17
ENV SPIGOT_REV=latest
ENV BUILDTOOLS_URL="https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar"

RUN apt update
RUN apt -y install \
        dumb-init \
        openjdk-${JAVA_VERSION_MAJOR}-jdk \
        openjdk-${JAVA_VERSION_MAJOR}-jre

RUN apt -y install wget \
        git

RUN wget ${BUILDTOOLS_URL} -O BuildTools.jar && \
     java -jar BuildTools.jar --compile SPIGOT --rev ${SPIGOT_REV} && \
     mv `find . -maxdepth 1 -name 'spigot*jar'` ${CONTAINER_WORKDIR}/spigot.jar && \
     rm -rf ${CONTAINER_WORKDIR}/out

RUN rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*deb

# final stage
ARG DEB_RELEASE=bullseye
FROM debian:${DEB_RELEASE}

LABEL maintainer="Vincent Z"

ENV CONTAINER_WORKDIR=/spigotmc
ENV PERSIST_DIR=${CONTAINER_WORKDIR}/persist/

WORKDIR ${CONTAINER_WORKDIR}

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_VERSION_MAJOR=17

RUN apt update
RUN apt -y install --no-install-recommends \
        dumb-init \
        openjdk-${JAVA_VERSION_MAJOR}-jre-headless

RUN rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*deb

COPY --from=spigot-builder ${CONTAINER_WORKDIR}/spigot.jar ./

# change into dir where volume will be mounted
WORKDIR ${PERSIST_DIR}

COPY server.properties ./
RUN echo "eula=true" > ./eula.txt

VOLUME [ "${PERSIST_DIR}" ]

EXPOSE 25565/tcp
EXPOSE 25575/tcp

ENTRYPOINT [ "dumb-init" ]
CMD [ "java", "-jar", "${CONTAINER_WORKDIR}/spigot.jar", "--nogui" ]

