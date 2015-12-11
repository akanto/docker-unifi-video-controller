Docker container for UniFi video NVR controller
===============================================
Dockerisation of UniFi video controller.

Building docker image
---
The Dockerfile will provision the image with ubuntu:latest and all the required dependencies to run the UniFi video NVR controller.

The UniFi NVR controller repo will provide the .debs. The package requires mongodb, so if we don't include 10gen's official repo it will use stock Debian mongo instead (current state).

The supervisor.conf is provided to configure supervisord which is used to launch the UniFi controller daemon.

	docker build -t unifi-video .

or

	docker pull akanto/unifi-video:latest

Launching the UniFi video controller daemon
---
The following is a _rough_ overview of how to lunch / run the video controller container, you will need to amend host volume path and ports first.

To launch a container using the image created earlier:

	docker run -d --privileged \
		-p 1935:1935 -p 7443:7443 -p 7080:7080 -p 6666:6666 -p 554:554 -p 7447:7447 \
                -v /srv/data/apps/docker/unifi-video/data:/var/lib/unifi-video \
                -v /srv/data/apps/docker/unifi-video/logs:/var/log/unifi-video \
                 --name=unifi-video akanto/unifi-video:latest

Remember to adjust the ports and volume paths to suite your environment.
