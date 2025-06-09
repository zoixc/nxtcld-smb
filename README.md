# nxtcld-smb

This repo was vibe-coded with ChatGPT.

Custom Docker image based on `nextcloud:stable` with added packages like:

- `smbclient` (for external storage)
- `libsmbclient-dev`
- `ffmpeg`, `libreoffice`, `ghostscript` (for previews and docs)

## 🔄 Auto Rebuild Workflow

This image is automatically rebuilt and pushed to Docker Hub when a new stable version of the base Nextcloud image is released, using GitHub Actions to check for the base image update every 24 hours, and when the changes detected, build and push the new custom image.
