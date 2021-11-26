ARG DEB_RELEASE=buster
FROM debian:${DEB_RELEASE}

ENV DEBIAN_FRONTEND=noninteractive
LABEL maintainer="Vincent Z."

RUN apt update && \
    apt -y --no-install-recommends install \
        dumb-init \
        gnupg2

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key C208ADDE26C2B797
    
RUN echo "deb http://downloads.linux.hpe.com/SDR/repo/mcp/debian jessie/current non-free" > /etc/apt/sources.list.d/hp-mcp.list

RUN apt update && \
    apt -y --no-install-recommends install \
        gnupg2- \
        lsb-base \
        libidn11 \
        procps \
        bash \
        ssa \
        hpsmh

RUN update-alternatives --install /bin/sh sh `which bash` 10

RUN apt -y autoremove
RUN rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*deb

WORKDIR /setup
COPY setpw.sh ./
RUN chmod +x setpw.sh

VOLUME [ "/opt/hp/" ]

EXPOSE 2301/tcp
EXPOSE 2381/tcp 

ENV SMHD_PIDFILE=/opt/hp/hpsmh/logs/httpd.pid
ENV SSA_BIN=/opt/smartstorageadmin/ssa/bin/ssa

ENTRYPOINT [ "dumb-init" ]
CMD [ "sh", "-c", "/setup/setpw.sh && /etc/init.d/hpsmhd start && ${SSA_BIN} -start && tail -f --pid=`cat ${SMHD_PIDFILE}`" ]
#CMD [ "bash", "-c", "/opt/smartstorageadmin/ssa/init.d/hpessad start && tail -f --pid=`cat ${SMHD_PIDFILE}`" ]