# syntax=docker/dockerfile:1

ARG PHP_VERSION=8.5
FROM php:${PHP_VERSION}-fpm

# Enable SBOM attestations
ARG BUILDKIT_SBOM_SCAN_CONTEXT=true
ARG BUILDKIT_SBOM_SCAN_STAGE=true
ARG DEBUG

# Set working directory
WORKDIR /var/www/html
ENV APP_PATH=/var/www/html

LABEL org.opencontainers.image.source="https://github.com/devanoxltd/docker-laravel"
LABEL org.opencontainers.image.vendor="Devanox Private Limited"
LABEL org.opencontainers.image.authors="Mr Chetan <contact@mrchetan.com>"

# Install system dependencies, Nginx, and Supervisor
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    curl \
    git \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip sockets \
    && pecl install pcov \
    && docker-php-ext-enable pcov
# Install Node.js, npm, and Playwright
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm \
    && npm install -g playwright@latest \
    && npx playwright install --with-deps

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy configurations
COPY nginx.conf /etc/nginx/sites-available/default
COPY supervisord.conf /etc/supervisor/supervisord.conf

# Copy entrypoint
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Configure Laravel environment variables
ENV DOCUMENT_ROOT="public"
ENV LARAVEL_AUTO_MIGRATION=1
ENV LARAVEL_ENABLE_QUEUE_WORKER=0
ENV LARAVEL_ENABLE_SCHEDULER=1
ENV LARAVEL_ENABLE_HORIZON=0
ENV LARAVEL_ENABLE_PULSE=0
ENV LARAVEL_ENABLE_REVERB=0

EXPOSE 8080

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
