#!/bin/bash
DEB_RELEASE=bullseye
OUTDIR=debian-${DEB_RELEASE}
DEB_PACKAGES="resolvconf,dumb-init,dirmngr,ca-certificates,apt-transport-https,gnupg2"

mkdir ${OUTDIR}

debootstrap --arch=amd64 \
 --include=${DEB_PACKAGES} bullseye ${OUTDIR}

rm -f ${OUTDIR}/var/lib/apt/lists/*
rm -f ${OUTDIR}/var/cache/apt/archives/*deb

tar -C ${OUTDIR} -pczf ${PWD}/${DEB_RELEASE}.tgz .