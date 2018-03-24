FROM ubuntu:16.04
LABEL maintainer="fcwu.tw@gmail.com"

RUN sed -i 's#http://archive.ubuntu.com/#http://tw.archive.ubuntu.com/#' /etc/apt/sources.list

# built-in packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends software-properties-common curl dialog \
    && sh -c "echo 'deb http://download.opensuse.org/repositories/home:/Horst3180/xUbuntu_16.04/ /' >> /etc/apt/sources.list.d/arc-theme.list" \
    && curl -SL http://download.opensuse.org/repositories/home:Horst3180/xUbuntu_16.04/Release.key | apt-key add - \
    && add-apt-repository ppa:fcwu-tw/ppa \
    && add-apt-repository -y ppa:sumo/stable \
    && apt-add-repository -y ppa:webupd8team/java \
    && apt-get update \
    && apt-get install -y --no-install-recommends --allow-unauthenticated \
        supervisor \
        sudo vim-tiny \
        net-tools \
        lxde x11vnc xvfb \
        gtk2-engines-murrine ttf-ubuntu-font-family \
        firefox \
        nginx \
        python-pip python-dev build-essential \
        mesa-utils libgl1-mesa-dri \
        gnome-themes-standard gtk2-engines-pixbuf gtk2-engines-murrine pinta arc-theme \
        dbus-x11 x11-utils \
        wget unzip nano git gedit \
        sumo sumo-tools sumo-doc
#    && apt-get autoclean \
#    && apt-get autoremove \
#    && rm -rf /var/lib/apt/lists/*

# VSimRTI additional packages
RUN export JAVA_HOME=/usr/lib/jvm/java-8-openjdk
RUN mkdir /home/vsimrti
RUN chown 1000:1000 -R /home/vsimrti
RUN wget https://www.dcaiti.tu-berlin.de/research/simulation/download/get/vsimrti-bin-17.0.zip
RUN unzip vsimrti-bin-17.0.zip -d /home
RUN rm vsimrti-bin-17.0.zip
RUN echo yes | apt-get install -y oracle-java8-installer
VOLUME /home/vsimrti
# RUN apt-get update --fix-missing

# tini for subreap
ARG TINI_VERSION=v0.9.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
RUN chmod +x /bin/tini

ADD image/usr/lib/web/requirements.txt /tmp/
RUN pip install setuptools wheel && pip install -r /tmp/requirements.txt
ADD image /

EXPOSE 80
WORKDIR /root
ENV HOME=/home/ubuntu \
    SHELL=/bin/bash
ENTRYPOINT ["/startup.sh"]
