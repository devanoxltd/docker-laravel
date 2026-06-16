# devanoxltd/docker-laravel

🔋 (PHP / Laravel) Production-ready Docker images with automatic Laravel installer.

- Docker Hub: https://hub.docker.com/r/devanoxpvtltd/laravel
- GitHub Packages: https://github.com/devanoxltd/docker-laravel/pkgs/container/laravel
- For inquiries, contact: info@devanox.com

The Docker images are available for both Debian and Alpine versions.


## Introduction

Our PHP Docker images, available on [Docker Hub](https://hub.docker.com/r/devanoxpvtltd/laravel),
are designed for easy configuration of PHP and PHP-FPM settings via environment variables.
This approach eliminates the need to rebuild images when making configuration changes.

These images also come with the latest version of [Composer](https://getcomposer.org),
enabling you to start projects quickly without additional installations.


## Usage

[![devanoxltd/docker-laravel](https://opengraph.githubassets.com/1/devanoxltd/docker-laravel)](https://github.com/devanoxltd/docker-laravel)

Check out [our documentation](https://github.com/devanoxltd/docker-laravel) to learn how to customize these Docker images for your projects.


## Creating a New Project

When you mount an empty directory into the container, it will automatically download the entire source code for the framework, allowing you to bootstrap a new project quickly.

### Steps to Create a New Project

1. Create an empty directory on your host machine for your project code. For example:

```shell
mkdir laravel
```

2. Run the container and mount the empty directory as a volume. For example:

```shell
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v ./laravel:/var/www/html \
    devanoxpvtltd/laravel:latest
```

The container will detect the empty directory mounted to `/var/www/html` and clone the framework source code into it.


## Using an Existing Project

You can mount your application code from your host machine to the `/var/www/html` directory inside the container.

Because the source code is mounted as a volume,
any changes made on the host machine will be reflected inside the container.
This setup allows you to run builds, tests,
and other tasks within the container while keeping your code on the host.


## Using HTTPS

The Docker images come with pre-generated SSL certificate files for testing HTTPS locally:

- /etc/ssl/site/server.crt
- /etc/ssl/site/server.key

To use valid HTTPS certificates for your production website,
replace these files with your own valid SSL certificates.
You can do this by copying or mounting your certificates from the host machine into the container.
Simply overwrite the default certificate files with your valid certificate and key files
to enable true HTTPS for your production website.

#### Using Dockerfile

```Dockerfile
FROM devanoxpvtltd/laravel:latest

# Copy your own certs into the container
COPY my_domain.crt /etc/ssl/site/server.crt
COPY my_domain.key /etc/ssl/site/server.key

# Add your instructions here
# For example:
# ADD --chown=$APP_USER:$APP_GROUP ./laravel/ /var/www/html/
```

#### Using docker run

```shell
docker run -p 80:80 -p 443:443 -p 443:443/udp \
    -v ./laravel:/var/www/html \
    -v ./my_domain.crt:/etc/ssl/site/server.crt \
    -v ./my_domain.key:/etc/ssl/site/server.key \
    devanoxpvtltd/laravel:latest
```

#### Using docker-compose

```yml
services:
  web:
    image: devanoxpvtltd/laravel:latest
    volumes:
      - ./laravel:/var/www/html
      - ./my_domain.crt:/etc/ssl/site/server.crt
      - ./my_domain.key:/etc/ssl/site/server.key
```


## Environment variables

You can optionally set the following environment variables in the container to enable certain services to run alongside the web server.

> 📝 Note: you'll need to install the required packages and create the necessary configs yourself for features like Laravel Pulse, Laravel Horizon or Laravel Reverb.

| Environment Variable             | Description             |
|----------------------------------|-------------------------|
| `LARAVEL_AUTO_MIGRATION`         | Whether to automatically run database migrations when the app boots. Set to `0` to disable running migration. **Default is `1`**. |
| `LARAVEL_AUTO_MIGRATION_OPTIONS` | Additional options/flags to pass to the `artisan migrate` command (e.g. `--seed`). |
| `LARAVEL_ENABLE_QUEUE_WORKER`    | Enables supervisor service for the Laravel queue worker. Set to `1` to start processing jobs. **Default is `0`**. |
| `LARAVEL_QUEUE_WORKER_OPTIONS`   | Defines custom options for the Laravel queue worker (e.g., connection, delay). |
| `LARAVEL_ENABLE_SCHEDULER`       | Enables supervisor service for the Laravel scheduler. Set to `0` to disable running scheduled tasks. **Default is `1`**. |
| `LARAVEL_SCHEDULER_OPTIONS`      | Specifies additional options for the scheduler execution. |
| `LARAVEL_ENABLE_HORIZON`         | Enables supervisor service for Laravel Horizon, a dashboard for managing queues. **Default is `0`**. |
| `LARAVEL_HORIZON_OPTIONS`        | Options for customizing Laravel Horizon behavior (e.g., environment, queue names). |
| `LARAVEL_ENABLE_PULSE`           | Enables supervisor service for Laravel Pulse for application performance monitoring. **Default is `0`**. |
| `LARAVEL_PULSE_OPTIONS`          | Configuration options for Laravel Pulse (e.g., port, storage). |
| `LARAVEL_ENABLE_REVERB`          | Enables supervisor service for Laravel Reverb for real-time WebSocket communication. **Default is `0`**. |
| `LARAVEL_REVERB_OPTIONS`         | Configuration options for Laravel Reverb (e.g., port, storage). |


## Stable Image Tags

The release versions on [this GitHub repository](https://github.com/devanoxltd/docker-laravel) don't guarantee
that Docker images built from the same source code will always be identical.

We build new Docker images weekly to ensure they stay up-to-date
with the latest upstream updates for PHP, base OS, Composer, etc.
The images in this repo are regularly updated under the same tag names.

But you can pull the image from `devanoxpvtltd/laravel:latest`,
and tag it with a name that indicates its stability,
such as `your-repo/laravel:stable` using the below commands:

```shell
docker pull devanoxpvtltd/laravel:latest
docker tag  devanoxpvtltd/laravel:latest your-repo/laravel:stable
docker push your-repo/laravel:stable
```

Then use the image `your-repo/laravel:stable` as a base image to build containers for production.


## Contributing

If you find these images useful, consider donating via [PayPal](https://www.paypal.me/devanox) or opening an issue on [GitHub](https://github.com/devanoxltd/docker-laravel/issues/new).

Your support helps maintain and improve these images for the community.


## License

This project is licensed under the terms of the [GNU General Public License v3.0](https://github.com/devanoxltd/docker-laravel/blob/main/LICENSE).

Thank you for recognizing the intellectual effort behind this project. If you plan to use or build upon any of its ideas, I kindly ask that you give appropriate credit to Devanox Private Limited (info@devanox.com).

