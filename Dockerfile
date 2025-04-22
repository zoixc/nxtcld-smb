FROM nextcloud:stable

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    smbclient \
    libsmbclient-dev \
    libldap-2.4-2 \
    ffmpeg \
    libreoffice \
    ghostscript \
 && apt-get clean && rm -rf /var/lib/apt/lists/*
