FROM ubuntu:latest
MAINTAINER Daniel Kristiyanto

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /root

## REQUIRED PACKAGES
RUN apt-get update && apt-get install -yq git x11vnc wget nano unzip xvfb openbox lxappearance rox-filer geany menu gtk2-engines-murrine \
    gtk2-engines-pixbuf build-essential python3 python3-dev python3-pip virtualenv libssl-dev \
    net-tools feh python3-pyqt5 libqt5webkit5-dev python3-pyqt5.qtsvg \
    python3-pyqt5.qtwebkit && \
    apt-get clean && apt-get autoclean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

## NOVNC
RUN git clone https://github.com/kanaka/noVNC.git && \
    cd noVNC/utils && git clone https://github.com/kanaka/websockify websockify

## ORANGE3
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN virtualenv --python=python3 --system-site-packages orange3venv
RUN source orange3venv/bin/activate
RUN git clone https://github.com/biolab/orange3.git 
RUN pip3 install --upgrade pip
RUN pip install numpy
RUN pip3 install -r orange3/requirements-core.txt
RUN pip3 install -r orange3/requirements-gui.txt
RUN pip3 install docker pysam
RUN pip3 install -e orange3

## BIODEPOT
ADD biodepot biodepot
RUN pip3 install -e biodepot

## DESKTOP SETTINGS
ADD Desktop/menu.xml  /root/.config/openbox/menu.xml 
ADD Desktop/bg.png /root/.config/openbox/bg.png
RUN echo "feh --bg-fill /root/.config/openbox/bg.png & rox-filer /data & orange-canvas" \ 
    >> /root/.config/openbox/autostart
ENV QT_STYLE_OVERRIDE=gtk
ADD Desktop/rc.xml /root/.config/openbox/rc.xml
ADD Desktop/Victory-16.10 /root/.themes/Victory-16.10
ADD Desktop/Victory-16.10-gtk2med-dark /root/.themes/Victory-16.10-gtk2med-dark
ADD Desktop/Flat-Remix /root/.icons/Flat-Remix
ADD Desktop/settings.ini /root/.config/gtk-3.0/settings.ini
ADD Desktop/gtkrc-2.0 /root/.gtkrc-2.0

## CMD
ADD Desktop/novnc.sh /root/novnc.sh
RUN chmod 0755 /root/novnc.sh

EXPOSE 6080

## START
WORKDIR /data
CMD /root/novnc.sh

