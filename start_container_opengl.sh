#!/bin/bash

docker stop $(docker ps -aqf "name=px4_sitl_docker")
docker rm $(docker ps -aqf "name=px4_sitl_docker")

xhost +local:docker

# --device=/dev/video0:/dev/video0
# For non root usage:
# RUN sudo usermod -a -G video developer

docker run \
    --volume=/tmp/.X11-unix:/tmp/.X11-unix \
    --device=/dev/dri:/dev/dri \
    --env="DISPLAY=$DISPLAY" \
    -e "TERM=xterm-256color" \
    --name px4_sitl_docker \
    px4_sitl_docker:latest \
    bash
