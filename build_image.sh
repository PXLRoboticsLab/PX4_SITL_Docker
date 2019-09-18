#!/bin/bash

(sudo apt install -y mesa-utils)

vendor=`glxinfo | grep vendor | grep OpenGL | awk '{ print $4 }'`

if [ $vendor == "NVIDIA" ]; then
    (docker build -t px4_sitl_docker_nvidia:latest -f ./dockerfile/nvidia/Dockerfile .)
else
    (docker build -t px4_sitl_docker_opengl:latest -f ./dockerfile/opengl/Dockerfile .)
fi
