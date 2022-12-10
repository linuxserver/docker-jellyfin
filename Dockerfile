# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

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
  echo "**** install jellyfin *****" && \
  curl -s https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key | apt-key add - && \
  echo 'deb [arch=amd64] https://repo.jellyfin.org/ubuntu jammy main' > /etc/apt/sources.list.d/jellyfin.list && \
  if [ -z ${JELLYFIN_RELEASE+x} ]; then \
    JELLYFIN="jellyfin-server"; \
  else \
    JELLYFIN="jellyfin-server=${JELLYFIN_RELEASE}"; \
  fi && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    at \
    ${JELLYFIN} \
    jellyfin-ffmpeg5 \
    jellyfin-web \
    libfontconfig1 \
    libfreetype6 \
    libssl3 \
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
