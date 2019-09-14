#!/bin/bash

docker build -t px4_sitl_docker_opengl:latest -f ./dockerfile/opengl/Dockerfile .
