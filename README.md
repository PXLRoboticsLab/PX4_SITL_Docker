# SITL Gazebo Docker

This project contains a Dockerfile and its dependencies to run ROS Melodic, Gazebo, PyCharm, ... in a container with hardware acceleration using nvidia-docker or OpenGL.

## Prerequisites

- Native Linux (Ubuntu, Debian and CentOS are supported)
- [Docker CE](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04) installed
- [Git Large File Storage (LFS) ](https://git-lfs.github.com/) installed

## General information

### Predefined versions

This project has already cloned several repositories. The two most important are [PX4/Firmware](https://github.com/PX4/Firmware.git) and [mavlink/mavros](https://github.com/mavlink/mavros.git).

- mavlink/mavros is set to release 0.31.0 (can be changed [here](https://github.com/PXLRoboticsLab/PX4_SITL_Docker/blob/master/Dockerfile#L92))
- PX4/Firmware is set to release 1.9.2 (can be changed [here](https://github.com/PXLRoboticsLab/PX4_SITL_Docker/blob/master/Dockerfile#L125))

### Installation locations

- Firmware is located at ~/Projects/Firmware
- mavros is located at /opt/PXL/catkin_ws/src/mavros
- catkin is located at ~/Projects/catkin

## Setup and usage

### 1. Clone the repository using `git lfs`

There is a large file in this repository. It is stored using Git Large File Storage (LFS). First clone the repository like usual. Then change your directory to where the repository is located. Finally perform `git lfs pull` to download the large file.

```bash
$ git clone https://github.com/PXLRoboticsLab/PX4_SITL_Docker
$ cd PX4_SITL_Docker
$ git lfs pull
```

### 2. Build the image

The following script will download and install all the dependencies, including ROS Melodic, Gazebo and PyCharm. When completed it should show up in the output of `docker image ls` as `px4_sitl_docker`.

#### 2.1. NVIDIA

If your computer has a NVIDIA GPU and [nvidia-docker](https://github.com/NVIDIA/nvidia-docker) installed, then you can use the dockerfile with your GPU enabled. A simple bash script to build the image is included in this repository.

```bash
$ ./build_image_nvidia.sh
```

#### 2.2. OpenGL

If your computer hasn't got a NVIDIA GPU, then you can use the OpenGL variant. A simple bash script to build the image is included in this repository.

```bash
$ ./build_image_opengl.sh
```

### 3. Create a container

Execute the provided bash script called `start_container.sh`. This will create a new container with the name 'px4_sitl_docker' with your GPU enabled inside the container.

### 4. Using the container

The container will start a simple bash environment. The terminal multiplexer `tmux` is also present. It's advised to use it if multiple bash shells are needed. For example, to run Gazebo together with other programs.

A `tmux` [cheat sheet](documents/tmux.pdf) is included in this repository.

The directory `~/Projects/catkin_ws/src` on the docker container is linked to the directory `src` in this repository.

When all processes finish, the container will stop. It's still present on the host. To restart it and interact with with a new bash console, execute the following command. The `-a` flag will attach your terminal to the docker container.

```bash
$ docker start -a px4_sitl_docker
```

### 5. Removing the container

The container can be removed when it will not be used anymore. The container can be removed by executing the bash script `remove_container.sh`.

```bash
$ ./remove_container.sh
```
