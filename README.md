# nxtcld-smb

This repo was vibe-coded with ChatGPT.

There are three image tags available: 
- `:stable`, which uses `nextcloud:stable` image with added `smbclient`, `geoip-bin`, `geoip-database`;
- `:latelight`, which uses `nextcloud:latest` image with the same additions as `smbclient`, `geoip-bin`, `geoip-database`;
- `:latest`, which uses `nextcloud:latest` image with more packages: `smbclient`, `libsmbclient-dev`, `ffmpeg`, `libreoffice`, `ghostscript`, `geoip-bin`, `geoip-database`.

Why these?
- `smbclient`, `libsmbclient-dev` - for external storage
- `geoip-bin`, `geoip-database` - for GeoBlocker app with GeoIpLookup service (latest DB dated 2025-03-28)
- `ffmpeg`, `libreoffice`, `ghostscript` - for previews and docs

The image size will be different with each tag, hence choose the most sutable option for you.

## Auto Rebuild Workflow

This image is automatically rebuilt and pushed to Docker Hub when a new stable version of the base Nextcloud image is released, using GitHub Actions to check for the base image update every 24 hours, and when the changes detected, build and push the new custom image.

## Installation
<details>
  <summary>Spin up this docker-compose.yml file to get Nextcloud + MariaDB + Valkey instance running</summary>


```  
services:
  nextcloud:
    image: ptabi/nxtcld-smb:light
    #image: nextcloud:stable
    container_name: nextcloud
    restart: unless-stopped
    ports:
      - "9999:80"
    volumes:
      - {your_path}/nextcloud:/var/www/html
    environment:
      MYSQL_HOST: db
      MYSQL_DATABASE: nextcloud
      MYSQL_USER: nextcloud
      MYSQL_PASSWORD: your_mysql_password
      MYSQL_ROOT_PASSWORD: your_mysql_root_password
      NEXTCLOUD_ADMIN_USER: your_admin_login
      NEXTCLOUD_ADMIN_PASSWORD: your_admin_password
      REDIS_HOST: valkey
    depends_on:
      - db
      - valkey
    networks:
      - nextcloud_network

  db:
    image: mariadb:latest #mariadb:11.4 is recommended as the latest image supported by Nextcloud; newer versions will throw a warning in settings but still will work fine (tested)
    container_name: nextcloud_db
    restart: always
    command: --transaction-isolation=READ-COMMITTED --log-bin=binlog --binlog-format=ROW
    volumes:
      - {your_path}/mariadb:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: your_mysql_root_password
      MYSQL_PASSWORD: your_mysql_password
      MYSQL_DATABASE: nextcloud
      MYSQL_USER: nextcloud
    networks:
      - nextcloud_network

  valkey:
    image: valkey/valkey:latest
    container_name: valkey
    restart: unless-stopped
    volumes:
      - {your_path}/valkey:/data #if you're transitioning from Redis you can preserve your custom path but you need to delete or rename dump.rdb in that folder and change all of your variables from redis to valkey)
    networks:
      - nextcloud_network

networks:
  nextcloud_network:
    name: nextcloud_network
    driver: bridge
```

</details>


## Fixing issues

1. To launch Cron background tasks worker run in your terminal: 
```
sudo crontab -e

*/5 * * * * docker exec -u www-data nextcloud php -f /var/www/html/cron.php
```

Or check working of this command manually:
```
sudo docker exec -u www-data nextcloud php -f /var/www/html/cron.php
```

2. To enable HSTS headers update file `/var/www/html/config/config.php` inside the container or on the host:

```bash
sudo docker exec -it nextcloud bash
nano /var/www/html/config/config.php
```

Add these lines (change `example.com` to your personal instance):

```
'overwrite.cli.url' => 'https://nextcloud.example.com',
'overwritehost' => 'nextcloud.example.com',
'overwriteprotocol' => 'https',
```

Restart the container:

```bash
sudo docker restart nextcloud
```

Add correct headers (for example using NPM) - paste this on the Advanced tab of your proxy host:

```
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Permitted-Cross-Domain-Policies "none" always;
add_header X-Robots-Tag "noindex, nofollow" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
```

Check your Nextcloud URL:

```bash
curl -I https://nextcloud.example.com/status.php
```

