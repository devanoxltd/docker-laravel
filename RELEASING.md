# Releasing

This project uses GitHub Actions to automate the building and publishing of Docker images.

## Overview

We do not use semantic versioning for our Docker image tags (like `v1.0.0`). Instead, we tag our images by the **PHP version** they contain (e.g., `:8.5`, `:8.4`, `:8.3`, etc.), with the highest stable PHP version also receiving the `:latest` tag.

Because we build new Docker images to ensure they stay up-to-date with upstream OS packages and security patches, the images behind a given tag (like `:8.5`) are designed to be "rolling releases".

## How to Trigger a Release

You can trigger a fresh build and push of all images across all supported PHP versions in two ways:

### 1. Merging to `main`

Any commit pushed or merged directly into the `main` branch will automatically trigger the `.github/workflows/docker-publish.yml` workflow. This will build and push the new images to Docker Hub and GitHub Container Registry (GHCR).

### 2. Creating a Release Tag

If you have made significant changes to the Dockerfile, entrypoint scripts, or base configuration, you may want to cut a formal GitHub Release for tracking purposes.

1. Go to the **Releases** section on the GitHub repository homepage.
2. Click **Draft a new release**.
3. Under "Choose a tag", type a new tag version following semantic versioning, prefixed with `v` (e.g., `v1.0.0` or `v1.0.1`) and select **Create new tag**.
4. Set the Target branch to `main`.
5. Provide a Release title (usually matching the tag, e.g., `Release v1.0.0`) and describe the changes or improvements made in this release.
6. Click **Publish release**.

Publishing a tag that matches the `v*.*.*` pattern will immediately trigger the GitHub Actions build matrix, pushing fresh images for all supported PHP versions to Docker Hub and GHCR.
