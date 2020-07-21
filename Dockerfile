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
 echo "**** install jellyfin *****" && \
 curl -s https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key | apt-key add - && \
 echo 'deb [arch=amd64] https://repo.jellyfin.org/ubuntu bionic main' > /etc/apt/sources.list.d/jellyfin.list && \
 if [ -z ${JELLYFIN_RELEASE+x} ]; then \
        JELLYFIN="jellyfin"; \
 else \
        JELLYFIN="jellyfin=${JELLYFIN_RELEASE}"; \
 fi && \
 apt-get update && \
 apt-get install -y --no-install-recommends \
	at \
	i965-va-driver \
	${JELLYFIN} \
	libfontconfig1 \
	libfreetype6 \
	libssl1.1 \
	mesa-va-drivers && \
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
