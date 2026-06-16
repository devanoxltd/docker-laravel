# Releasing

This project uses GitHub Actions to automate the building and publishing of Docker images.

## Overview

We do not use semantic versioning for our Docker image tags (like `v1.0.0`). Instead, we tag our images by the **PHP version** they contain (e.g., `:8.5`, `:8.4`, `:8.3`, etc.), with the highest stable PHP version also receiving the `:latest` tag.

Because we build new Docker images to ensure they stay up-to-date with upstream OS packages and security patches, the images behind a given tag (like `:8.5`) are designed to be "rolling releases".

## How to Trigger a Release

You can trigger a fresh build and push of all images across all supported PHP versions in two ways:

### 1. Automated Weekly Schedule

The `.github/workflows/docker-publish.yml` workflow is scheduled to run automatically every week. This ensures that the Docker images are continuously rebuilt with the latest upstream OS packages, security patches, and PHP minor updates.

### 2. Publishing a GitHub Release

If you have made significant changes to the Dockerfile, entrypoint scripts, or base configuration, you can manually trigger a build by publishing a formal GitHub Release:

1. Go to the **Releases** section on the GitHub repository homepage.
2. Click **Draft a new release**.
3. Under "Choose a tag", type a new tag version (e.g., `v1.0.0`) and select **Create new tag**.
4. Set the Target branch to `main`.
5. Provide a Release title and describe the changes or improvements made in this release.
6. Click **Publish release**.

Publishing the release will immediately trigger the GitHub Actions build matrix, pushing fresh images for all supported PHP versions to Docker Hub and GHCR.
