# nxtcld-smb

This repo was vibe-coded with ChatGPT.

Custom Docker image based on `nextcloud:stable` with added packages like:

- `smbclient` (for external storage)
- `libsmbclient-dev`
- `ffmpeg`, `libreoffice`, `ghostscript` (for previews and docs)

## Auto Rebuild Workflow

This image is automatically rebuilt and pushed to Docker Hub when a new stable version of the base Nextcloud image is released, using GitHub Actions to check for the base image update every 24 hours, and when the changes detected, build and push the new custom image.

## Installation
<details>
  <summary>Spin up this docker-compose.yml file to get Nextcloud + MariaDB + redis instance running</summary>


```  
services:
  nextcloud:
    image: ptabi/nxtcld-smb:latest
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
      REDIS_HOST: redis
    depends_on:
      - db
      - redis
    networks:
      - nextcloud_network

  db:
    image: mariadb:11.4
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

  redis:
    image: redis:alpine
    container_name: redis
    restart: unless-stopped
    volumes:
      - {your_path}/redis:/data
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

Add correct headers (for example using NPM) - paste this on the Advanced tab of your host:

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

