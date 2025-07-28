# nxtcld-smb

This repo was vibe-coded with ChatGPT.

Custom Docker image based on `nextcloud:stable` with added packages like:

- `smbclient` (for external storage)
- `libsmbclient-dev`
- `ffmpeg`, `libreoffice`, `ghostscript` (for previews and docs)

## Auto Rebuild Workflow

This image is automatically rebuilt and pushed to Docker Hub when a new stable version of the base Nextcloud image is released, using GitHub Actions to check for the base image update every 24 hours, and when the changes detected, build and push the new custom image.

## Installation
Check `docker-compose-example.yml` file in the repo to see an example working config with mariadb and redis.

## Fixing issuess

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

