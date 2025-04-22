# nxtcld-smb

This repo was vibe-coded with ChatGPT.

Custom Docker image based on `nextcloud:stable` with added packages like:

- `smbclient` (for external storage)
- `libsmbclient-dev`
- `ffmpeg`, `libreoffice`, `ghostscript` (for previews and docs)

## 🔄 Auto Rebuild Workflow

This image is automatically rebuilt and pushed to Docker Hub when a new stable version of the base Nextcloud image is released, using:

- [Diun](https://crazymax.dev/diun/) to detect image updates
- GitHub Actions to build and push the new custom image
