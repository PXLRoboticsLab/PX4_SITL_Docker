#!/bin/bash

docker build -t px4_sitl_docker:latest -f ./dockerfile/opengl/Dockerfile .
