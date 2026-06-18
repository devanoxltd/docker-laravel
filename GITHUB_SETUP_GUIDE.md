# GitHub Actions Setup Guide

This guide explains how to set up this repository to automatically build and publish the Docker images to Docker Hub and GitHub Container Registry (GHCR) using GitHub Actions.

## Multi-Version PHP Support

This repository uses a **Build Matrix** in GitHub Actions. Whenever you push to the `main` branch or create a Release Tag (`v*.*.*`), GitHub Actions will spin up multiple parallel jobs to build the Docker image for each supported PHP version.

Currently supported versions:
- `8.2`
- `8.3`
- `8.4`
- `8.5` *(Tagged as `latest` as well)*

The resulting images will be tagged automatically. For example, it will produce:
- `devanoxpvtltd/laravel:8.2` (on Docker Hub)
- `ghcr.io/devanoxltd/laravel:8.2` (on GitHub Container Registry)
- `devanoxpvtltd/laravel:8.3`
... and so on.

## Initial Setup

To allow GitHub Actions to push to your Docker Hub account, you must configure **Repository Secrets**.

### Step 1: Generate a Docker Hub Access Token
1. Log in to [Docker Hub](https://hub.docker.com/).
2. Click on your profile picture in the top right and select **Account settings**.
3. Go to **Security** -> **New Access Token**.
4. Give it a description (e.g., "GitHub Actions Laravel") and grant it **Read & Write** permissions.
5. Copy the generated token. You will need this for Step 2.

### Step 2: Add Secrets to GitHub
1. Go to your GitHub repository: `https://github.com/devanoxltd/docker-laravel`.
2. Click on the **Settings** tab.
3. In the left sidebar, scroll down to **Secrets and variables** and click on **Actions**.
4. Click the **New repository secret** button.
5. Add the following two secrets:

    - **Name:** `DOCKERHUB_USERNAME`
      **Secret:** Your Docker Hub username (e.g., `devanoxpvtltd`)
      
    - **Name:** `DOCKERHUB_TOKEN`
      **Secret:** The access token you generated in Step 1.

### Step 3: Trigger a Build
1. Make a commit and push to the `main` branch.
2. Go to the **Actions** tab in your GitHub repository.
3. You will see the `Docker` workflow running. Clicking on it will reveal the parallel jobs building each PHP version.
4. Once completed, your images will be available on Docker Hub and GHCR!

## Changing the "Latest" Tag
By default, the `8.5` build is also tagged as `latest`. If you want to change this (for example, to make `8.4` the latest), edit the `.github/workflows/docker-publish.yml` file and change this line under the metadata action:

```yaml
type=raw,value=latest,enable=${{ matrix.php-version == '8.5' }}
```
Change `'8.5'` to your preferred latest version.
