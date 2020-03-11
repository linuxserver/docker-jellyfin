FROM lsiobase/ubuntu:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
ARG JELLYFIN_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y --no-install-recommends \
	gnupg && \
 echo "**** add jellyfin deps *****" && \
 curl -s https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key | apt-key add - && \
 echo 'deb [arch=amd64] https://repo.jellyfin.org/ubuntu bionic main' > /etc/apt/sources.list.d/jellyfin.list && \
 apt-get update && \
 apt-get install -y --no-install-recommends \
	at \
	i965-va-driver \
	jellyfin-ffmpeg \
	libfontconfig1 \
	libfreetype6 \
	libssl1.0.0 \
	mesa-va-drivers && \
 echo "**** install jellyfin *****" && \
 if [ -z ${JELLYFIN_RELEASE+x} ]; then \
	JELLYFIN="jellyfin-nightly"; \
 else \
	JELLYFIN="jellyfin-nightly=${JELLYFIN_RELEASE}"; \
 fi && \
 apt-get install -y \
	${JELLYFIN} && \
 echo "**** cleanup ****" && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY root/ / 

# ports and volumes
EXPOSE 8096 8920
VOLUME /config
