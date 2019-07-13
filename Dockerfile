FROM nvidia/cudagl:9.2-devel-ubuntu18.04

# We love UTF!
ENV LANG C.UTF-8

RUN set -x \
        && apt-get update \
        && apt-get upgrade -y \
        && apt-get install -y apt-transport-https ca-certificates \
        && apt-get install -y git vim htop sudo curl wget mesa-utils \
        && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash user \
    && echo "user:user" | chpasswd && adduser user sudo \
    && usermod -aG audio user

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
        && apt-get install -y software-properties-common \
        && apt-get update \
        && apt-get install -y libnss3 \
        && rm -rf /var/lib/apt/lists/*

USER user
WORKDIR /home/user
#
# Set some decent colors if the container needs to be accessed via /bin/bash.
RUN echo LS_COLORS=$LS_COLORS:\'di=1\;33:ln=36\' >> ~/.bashrc \
&& echo export LS_COLORS >> ~/.bashrc \
&& touch ~/.sudo_as_admin_successful # To surpress the sudo message at run.

ENV NVIDIA_REQUIRE_CUDA "cuda>=8.0"
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility,video,display

USER root
# setup timezone
RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get update && apt-get install -q -y tzdata && rm -rf /var/lib/apt/lists/*

# install packages
RUN apt-get update && apt-get install -q -y \
    dirmngr \
    gnupg2 \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# setup sources.list
RUN echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list

RUN apt-get update \
        && apt-get install -y ros-melodic-desktop-full \
        && apt-get install -y python-rosinstall python-rosinstall-generator python-wstool build-essential \
        && rm -rf /var/lib/apt/lists/* \
        && rosdep init

USER user
RUN rosdep update \
        && echo "source /opt/ros/melodic/setup.bash" >> /home/user/.bashrc

USER root
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN apt-get update \
        && apt-get install -y tmux \
        && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/PXL/catkin_ws/src



RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list' 
RUN wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
RUN apt-get update
RUN apt-get install apt-utils -y
RUN apt-get install gazebo9 libignition-math2 python-jinja2 libignition-math2-dev protobuf-compiler \
 libeigen3-dev libopencv-dev build-essential genromfs ninja-build exiftool \
 astyle python-argparse python-empy python-toml python-numpy python-dev python-pip \
 ros-melodic-mavros ros-melodic-mavros-extras python-catkin-tools python-rosinstall-generator -y

RUN apt-get upgrade libignition-math2-dev -y

RUN pip install --upgrade pip
RUN pip install pandas jinja2 pyserial pyyaml

RUN git clone https://github.com/mavlink/mavros.git /opt/PXL/catkin_ws/src/mavros
RUN /bin/bash -c 'cd /opt/PXL/catkin_ws/src/mavros ; git checkout 0.31.0; cd ~'
RUN bash /opt/PXL/catkin_ws/src/mavros/mavros/scripts/install_geographiclib_datasets.sh

RUN /bin/bash -c '. /opt/ros/melodic/setup.bash; cd /opt/PXL/catkin_ws; catkin_make'

RUN echo "source /opt/PXL/catkin_ws/devel/setup.bash" >> /home/user/.bashrc

COPY ./scripts/init_commands.sh /scripts/init_commands.sh
RUN ["chmod", "+x", "/scripts/init_commands.sh"]

USER user
WORKDIR /home/user
RUN mkdir -p Projects/catkin_ws/src 
RUN mkdir -p Programs/PyCharm
COPY ./pycharm-community-2019.1.1.tar.gz Programs/PyCharm/
WORKDIR /home/user/Programs/PyCharm
RUN tar xvf ./pycharm-community-2019.1.1.tar.gz
RUN rm ./pycharm-community-2019.1.1.tar.gz
WORKDIR /home/user
COPY ./PyCharmCE2019.1.tar.gz PyCharmCE2019.1.tar.gz
RUN tar xvf ./PyCharmCE2019.1.tar.gz
RUN rm ./PyCharmCE2019.1.tar.gz
COPY ./scripts/charm /usr/local/bin/charm

RUN /bin/bash -c '. /opt/ros/melodic/setup.bash; cd /home/user/Projects/catkin_ws; catkin_make'

RUN echo "source /home/user/Projects/catkin_ws/devel/setup.bash --extend" >> /home/user/.bashrc

RUN git clone https://github.com/jimeh/tmux-themepack.git ~/.tmux-themepack  \
&& git clone https://github.com/tmux-plugins/tmux-resurrect ~/.tmux-resurrect

# Arno alternations
RUN git clone https://github.com/PX4/Firmware.git ~/Programs/Firmware
RUN /bin/bash -c 'cd ~/Programs/Firmware; git checkout tags/v1.9.1; cd ~'


COPY ./.tmux.conf /home/user/.tmux.conf

STOPSIGNAL SIGTERM

ENTRYPOINT ["/scripts/init_commands.sh"]
CMD /bin/bash
