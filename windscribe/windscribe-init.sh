#!/bin/bash

IMAGE_TAG="vince2678/windscribe"
CONTAINER_PREFIX="windscribe-"
VOLUME_PREFIX="${CONTAINER_PREFIX}data-"
VOLUME_MOUNT="/etc/windscribe"
WRAPPER_PATH='/root/windscribe-wrapper.sh'
BASE_PORT=1080

function help()
{
    echo "       $0 (-h|--help)"
    echo "       $0 (-b|b|build)"
    echo "       $0 (-d|d|deploy)"
    echo "       $0 (start|stop|delete) [num]"
    exit 0
}

function get_vol_numbers {
    local vol_numbers=`docker volume ls | grep $VOLUME_PREFIX | grep -o "[0-9]*" | sort -n`
    echo $vol_numbers
}

function get_next_number {
    local nums=`get_vol_numbers`
    if [ -z "$nums" ]; then
        echo 1
        return
    fi

    for i in $nums; do
        p=$i;
    done;
    echo $(($p+1))
}

function build_image {
    # You may need to run this as root. I don't care.
    if ! [ -s "bullseye.tgz" ]; then
        echo "Creating base system image..."
        debootstrap.sh
        if [ "$?" -ne 0 ]; then
            exit 1
        fi
    fi

    echo "Building image..."
    docker build . -t ${IMAGE_TAG}
    if [ "$?" -ne 0 ]; then
        exit 1
    fi
}

function deploy_container {
    local num=`get_next_number`
    local port="$(($num+1))"
    local volume_name="${VOLUME_PREFIX}${num}"
    local container_name="${CONTAINER_PREFIX}${num}"

    echo "Creating volume..."
    docker volume create ${volume_name}
    if [ "$?" -ne 0 ]; then
        exit 1
    fi

    echo "Logging in..."
    docker run -it -v ${volume_name}:${VOLUME_MOUNT} \
        --rm ${IMAGE_TAG} bash -c "$WRAPPER_PATH login"
    if [ "$?" -ne 0 ]; then
        echo "Login failed. Deleting volume..."
        docker volume rm ${volume_name}
        exit 1
    fi

    echo "Creating container..."
    docker container create -t -v ${volume_name}:${VOLUME_MOUNT} \
        -p $port:${BASE_PORT} --name ${container_name} ${IMAGE_TAG}

    if [ "$?" -ne 0 ]; then
        echo "Create failed. Deleting..."
        delete_container $num
    fi
}

function start_container {
    local num="$1"
    if [ -z "$num" ]; then
        echo 'No suffix/number specified'
        exit 1
    fi

    local container_name="${CONTAINER_PREFIX}${num}"

    echo "Starting ${container_name}..."
    docker start ${container_name}
    exit $?
}

function stop_container {
    local num="$1"
    if [ -z "$num" ]; then
        echo 'No suffix/number specified'
        exit 1
    fi

    local container_name="${CONTAINER_PREFIX}${num}"

    echo "Stopping ${container_name}..."
    docker stop ${container_name}
    exit $?
}

function delete_container {
    local num="$1"
    if [ -z "$num" ]; then
        echo 'No suffix/number specified'
        exit 1
    fi

    local container_name="${CONTAINER_PREFIX}${num}"
    local volume_name="${VOLUME_PREFIX}${num}"

    echo "Stopping ${container_name}..."
    docker kill ${container_name} 2>/dev/null

    echo "Removing ${container_name}..."
    docker rm -v ${container_name}
    docker volume rm ${volume_name}
    exit $?
}

# Parse arguments
case "$1" in
    '-b'|'b'|'build')
        build_image
        exit $?
        ;;
    '-d'|'d'|'deploy')
        build_image
        deploy_container
        exit $?
        ;;
    'start')
        start_container $2
        ;;
    'stop')
        stop_container $2
        ;;
    'delete')
        delete_container $2
        ;;
    '-h'|'--help')
        help
        exit 1
        ;;
    *)
        help
        exit 1
        ;;
esac
