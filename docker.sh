#!/usr/bin/env bash
# Author: Michal Svorc <michalsvorc.com>
# Description: Docker commands helper script

#===============================================================================
# Script options
#===============================================================================

set -o errexit      # abort on nonzero exitstatus
set -o nounset      # abort on unbound variable
set -o pipefail     # don't hide errors within pipes
# set -o xtrace     # debugging

#===============================================================================
# Variables
#===============================================================================

# Docker arguments
application_name='react-native'
image_name="michalsvorc/${application_name}"

android_sdk_version='29'
android_build_tools_version='29.0.2'
nodejs_version='14'

image_tag="android-sdk-${android_sdk_version}"
container_name="michalsvorc_${application_name}-${image_tag}"

mount_workspace_source="${PWD}/workspace"
mount_workspace_target="/home/user/workspace"

#===============================================================================
# Help
#===============================================================================

_print_help() {
cat <<HELP
Usage: ./docker.sh [COMMAND]

Docker commands helper script

Commands:
    -h|--help       print this help text and exit
    build           build Docker image
    run             run Docker image
    start           start Docker container

HELP
}

#===============================================================================
# Functions
#===============================================================================

_die() {
    local error_message="${1}"
    printf 'Error: %s\nSee help for proper usage:\n\n' "${error_message}" >&2
	_print_help
    exit 1
}

_docker_build() {
    printf 'Docker build image %s\n' "${image_name}:${image_tag}"

    docker build \
        --build-arg android_sdk_version="${android_sdk_version}" \
        --build-arg android_build_tools_version="${android_build_tools_version}" \
        --build-arg nodejs_version="${nodejs_version}" \
        --tag "${image_name}:${image_tag}" \
        .
}

_docker_run() {
    printf 'Docker run image %s\n' "${image_name}:${image_tag}"

    docker run \
        -d \
        -it \
        --privileged \
        --env DISPLAY="${DISPLAY}" \
        -v '/tmp/.X11-unix:/tmp/.X11-unix' \
        -v '/dev/bus/usb:/dev/bus/usb' \
        --mount type=bind,source="${mount_workspace_source}",target="${mount_workspace_target}" \
        --name "${container_name}" \
        "${image_name}:${image_tag}" \
        bash
}

_docker_start() {
    printf 'Docker start container %s\n' "${container_name}"

    docker start "${container_name}"
}

#===============================================================================
# Execution
#===============================================================================

if [ $# -eq 0 ]; then
    _die 'No arguments provided'
fi

case "${1}" in
    -h|--help)
        _print_help
        ;;
    build)
        _docker_build
        ;;
    run)
        _docker_run
        ;;
    start)
        _docker_start
        ;;
    *)
        _die "Unknown argument '${1}'"
        ;;
esac
