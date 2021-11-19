#!/bin/sh

OVPN_DATA_TCP=ovpn-data-tcp
OVPN_DATA_UDP=ovpn-data-udp

SERVER_NAME=proliant.msm8916.com
CLIENT_NAME=default

docker volume create $OVPN_DATA_UDP
docker volume create $OVPN_DATA_TCP

# so, the script in the docker image runs
# openvpn on port 1194 regardless, so this
# is set to that in the compose file
docker run -v $OVPN_DATA_UDP:/etc/openvpn \
    --rm kylemanna/openvpn ovpn_genconfig \
    -e "management 0.0.0.0 5555" -z \
    -u "udp://${SERVER_NAME}:21195" \
    -n 1.1.1.1 -n 1.0.0.1

docker run -v $OVPN_DATA_TCP:/etc/openvpn \
    --rm kylemanna/openvpn ovpn_genconfig \
    -e "management 0.0.0.0 5555" -z \
    -u "tcp://${SERVER_NAME}:21195" \
    -n 1.1.1.1 -n 1.0.0.1

# create private keys
docker run -v ${OVPN_DATA_UDP}:/etc/openvpn --rm \
     -it kylemanna/openvpn ovpn_initpki

docker run -v ${OVPN_DATA_TCP}:/etc/openvpn --rm \
     -it kylemanna/openvpn ovpn_initpki

# Generate a client certificate without a passphrase
docker run -v ${OVPN_DATA_UDP}:/etc/openvpn --rm -it \
    kylemanna/openvpn easyrsa build-client-full ${CLIENT_NAME} nopass

docker run -v ${OVPN_DATA_TCP}:/etc/openvpn --rm -it \
    kylemanna/openvpn easyrsa build-client-full ${CLIENT_NAME} nopass

# Retrieve the client configuration with embedded certificates
docker run -v ${OVPN_DATA_UDP}:/etc/openvpn --rm \
    kylemanna/openvpn ovpn_getclient ${CLIENT_NAME} > ${CLIENT_NAME}-udp.ovpn

docker run -v ${OVPN_DATA_TCP}:/etc/openvpn --rm \
    kylemanna/openvpn ovpn_getclient ${CLIENT_NAME} > ${CLIENT_NAME}-tcp.ovpn