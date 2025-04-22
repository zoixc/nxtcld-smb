FROM nextcloud:stable

RUN apt-get update && apt-get install -y --no-install-recommends smbclient
RUN apt-get install -y --no-install-recommends libsmbclient-dev
RUN apt-get install -y --no-install-recommends libldap-2.5-0
RUN apt-get install -y --no-install-recommends ffmpeg
RUN apt-get install -y --no-install-recommends libreoffice
RUN apt-get install -y --no-install-recommends ghostscript
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
