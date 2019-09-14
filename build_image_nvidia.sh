#!/bin/bash

docker build -t px4_sitl_docker_nvidia:latest -f ./dockerfile/nvidia/Dockerfile .
