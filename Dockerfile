# build docker image to run the unifi video nvr controller
#
# the unifi nvr video contoller is used to admin ubiquity ip cameras
#
#
FROM ubuntu:14.04

ADD ./apt/ubuntu-sources.list /etc/apt/sources.list

# make apt non-interactive
ENV DEBIAN_FRONTEND noninteractive

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 16126D3A3E5C1192

RUN apt-get update -y && \
	  apt-get install -q -y curl wget supervisor apt-utils lsb-release curl wget rsync util-linux psmisc

RUN	mkdir -p /var/log/supervisor /data/logs /data/data && \
  	touch /data/.unifi-video

# add mongodb repo
RUN 	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && \
	echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/mongodb.list


# add ubnt repo
RUN 	wget -q -O -  http://www.ubnt.com/downloads/unifi-video/apt/unifi-video.gpg.key | apt-key add - && \
	echo "deb [arch=amd64] http://www.ubnt.com/downloads/unifi-video/apt trusty ubiquiti" | tee /etc/apt/sources.list.d/ubiquity-video.list

# update repos
RUN apt-get update -q -y

# grab unifi video controller, RUNLEVEL=1 is to stop running services on install
RUN RUNLEVEL=1 apt-get install -q -y unifi-video

VOLUME /var/lib/unifi-video
VOLUME /var/log/unifi-video

# The following ports are used on UniFi Video hosts:

# 1935 – RTMP streaming video to web UI & accepting gen1 camera video
# 1935, by user (RTMP video)

# 7443 – Controller web UI
# 7443, by user (HTTPS), by camera (HTTPS)

# 7080 – HTTP communication with cameras
# 7080, by user (HTTP), by camera (HTTP)

# 6666 – Live FLV for incoming gen2 camera streams
# 6666, by camera (video push)

# 7447 – RTSP re-streaming via controller

# The following ports are used on cameras:

# HTTP/HTTPS ports to access web interface (optional)
# SSH to facilitate adoption by the controller on LAN (optional)
# 554 RTSP server (mandatory only on gen1)

EXPOSE  7447 7446 1935 7443 7080 6666 554

# launcher config
ADD ./supervisord.conf /etc/supervisor/conf.d/unifi-video.conf
ADD ./unifi-video.default /etc/default/unifi-video


WORKDIR /usr/lib/unifi-video
CMD ["/usr/bin/supervisord"]
