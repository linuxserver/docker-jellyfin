FROM ghcr.io/linuxserver/baseimage-ubuntu:focal

# set version label
ARG BUILD_DATE
ARG VERSION
ARG JELLYFIN_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

# set Intel iHD driver versions
# https://dgpu-docs.intel.com/releases/index.html
ARG INTEL_LIBVA_VER="2.13.0+i643~u20.04"
ARG INTEL_GMM_VER="21.3.3+i643~u20.04"
ARG INTEL_iHD_VER="21.4.1+i643~u20.04"

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    gnupg && \
  echo "**** install jellyfin *****" && \
  curl -s https://repo.jellyfin.org/ubuntu/jellyfin_team.gpg.key | apt-key add - && \
  echo 'deb [arch=amd64] https://repo.jellyfin.org/ubuntu focal main' > /etc/apt/sources.list.d/jellyfin.list && \
  echo 'deb [arch=amd64] https://repo.jellyfin.org/ubuntu focal unstable' >> /etc/apt/sources.list.d/jellyfin.list && \
  curl -s https://repositories.intel.com/graphics/intel-graphics.key | apt-key add - && \
  echo 'deb [arch=amd64] https://repositories.intel.com/graphics/ubuntu focal main' > /etc/apt/sources.list.d/intel-graphics.list && \
  if [ -z ${JELLYFIN_RELEASE+x} ]; then \
    JELLYFIN="jellyfin-server"; \
  else \
    JELLYFIN="jellyfin-server=${JELLYFIN_RELEASE}"; \
  fi && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    at \
    libva2="${INTEL_LIBVA_VER}" \
    libigdgmm11="${INTEL_GMM_VER}" \
    intel-media-va-driver-non-free="${INTEL_iHD_VER}" \
    ${JELLYFIN} \
    jellyfin-ffmpeg \
    jellyfin-web \
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
