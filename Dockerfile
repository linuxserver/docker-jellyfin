# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-ubuntu:noble

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
  curl -fSsL https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key | gpg --dearmor | tee /usr/share/keyrings/jellyfin.gpg >/dev/null && \
  echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/jellyfin.gpg] https://repo.jellyfin.org/ubuntu noble main' > /etc/apt/sources.list.d/jellyfin.list && \
  echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/jellyfin.gpg] https://repo.jellyfin.org/ubuntu noble unstable' >> /etc/apt/sources.list.d/jellyfin.list && \
  if [ -z ${JELLYFIN_RELEASE+x} ]; then \
    JELLYFIN_RELEASE=$(curl -sX GET https://repo.jellyfin.org/ubuntu/dists/noble/unstable/binary-amd64/Packages |grep -A 7 -m 1 'Package: jellyfin-server' | awk -F ': ' '/Version/{print $2;exit}'); \
  fi && \
  apt-get update && \
  apt-get install -y \
    at \
    jellyfin-server=${JELLYFIN_RELEASE} \
    jellyfin-ffmpeg6 \
    mesa-va-drivers \
    xmlstarlet && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
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
