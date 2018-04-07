FROM ubuntu:16.04
LABEL maintainer="TelecomSteve"

RUN sed -i 's#http://archive.ubuntu.com/#http://tw.archive.ubuntu.com/#' /etc/apt/sources.list

# base install packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends software-properties-common \
    && add-apt-repository ppa:fcwu-tw/ppa \
    && add-apt-repository -y ppa:sumo/stable \
    && apt-add-repository -y ppa:webupd8team/java \
    && apt-get update \
    && apt-get install -y --no-install-recommends --allow-unauthenticated \
        supervisor \
        sudo vim-tiny net-tools lxde x11vnc xvfb python-software-properties debconf-utils \
        firefox nginx python-pip python-dev build-essential \
        mesa-utils libgl1-mesa-dri dbus-x11 x11-utils \
        dialog wget unzip nano git \
        sumo sumo-tools sumo-doc

# jdk 8 install
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
RUN apt-get install -y oracle-java8-installer

# vsimrti additional packages
RUN wget https://www.dcaiti.tu-berlin.de/research/simulation/download/get/vsimrti-bin-17.0.zip
RUN unzip vsimrti-bin-17.0.zip -d /root/Desktop
RUN rm vsimrti-bin-17.0.zip
RUN chmod +x /root/Desktop/vsimrti-allinone/vsimrti/firstStart.sh
RUN bash /root/Desktop/vsimrti-allinone/vsimrti/firstStart.sh

# Omnet++ additional packages
RUN apt-get install -y build-essential gcc g++ bison flex perl tcl-dev tk-dev blt libxml2-dev zlib1g-dev \
&& apt-get install -y doxygen graphviz libwebkitgtk-1.0-0 openmpi-bin libopenmpi-dev libpcap-dev \
&& apt-get install -y autoconf automake \
&& apt-get install -y libtool libproj-dev libfox-1.6-dev libgdal-dev libxerces-c-dev qt4-dev-tools

# libgdal1-dev

# tini for subreap
ARG TINI_VERSION=v0.9.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
RUN chmod +x /bin/tini

ADD image/usr/lib/web/requirements.txt /tmp/
RUN pip install setuptools wheel && pip install -r /tmp/requirements.txt
ADD image /

# desktop customization
ADD /desktop/panel /tmp/
ADD /desktop/slate.png /tmp/
RUN rm /etc/xdg/lxpanel/default/panels/panel
RUN rm /etc/xdg/lxpanel/LXDE/panels/panel
RUN cp /tmp/panel /etc/xdg/lxpanel/default/panels/panel
RUN cp /tmp/panel /etc/xdg/lxpanel/LXDE/panels/panel

EXPOSE 80
WORKDIR /root
ENV HOME=/home/ubuntu \
    SHELL=/bin/bash
ENTRYPOINT ["/startup.sh"]
