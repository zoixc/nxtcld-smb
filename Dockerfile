FROM nextcloud:stable

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        smbclient \
        libsmbclient-dev \
        ffmpeg \
        libreoffice \
        ghostscript \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
