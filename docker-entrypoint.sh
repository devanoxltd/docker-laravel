#!/usr/bin/env bash
set -e

# Setup default environment variables
export APP_PATH=${APP_PATH:-"/var/www/html"}
cd "$APP_PATH"

# Dynamically set Nginx document root
DOCUMENT_ROOT=${DOCUMENT_ROOT:-"public"}
sed -i "s|root /var/www/html/public;|root $APP_PATH/$DOCUMENT_ROOT;|g" /etc/nginx/sites-available/default

# Check if directory is empty and clone Laravel if so (as stated in README)
if [ ! -f "$APP_PATH/artisan" ] && [ ! -f "$APP_PATH/composer.json" ]; then
    # Check if directory is really empty or only contains lost+found
    if [ -z "$(ls -A "$APP_PATH" 2>/dev/null | grep -v 'lost+found')" ]; then
        echo "Empty directory detected. Installing fresh Laravel project..."
        composer create-project --prefer-dist laravel/laravel .
        # Setup proper permissions for the newly created project
        chown -R www-data:www-data "$APP_PATH"
    fi
fi

if [ -f "$APP_PATH/.env" ] && [ -f "$APP_PATH/artisan" ]; then
    if grep -qx -- 'APP_KEY=' "$APP_PATH/.env"; then
        php artisan key:generate || true
    fi

    if grep -qF -- 'DB_CONNECTION=sqlite' "$APP_PATH/.env"; then
        touch "$APP_PATH/database/database.sqlite" || true
    fi
fi

# Ensure storage and bootstrap/cache are writable by the web server
if [ -d "$APP_PATH/storage" ]; then
    chown -R www-data:www-data "$APP_PATH/storage" 2>/dev/null || true
fi
if [ -d "$APP_PATH/bootstrap/cache" ]; then
    chown -R www-data:www-data "$APP_PATH/bootstrap/cache" 2>/dev/null || true
fi

# Run Migrations
LARAVEL_AUTO_MIGRATION=${LARAVEL_AUTO_MIGRATION:-1}
if [ "$LARAVEL_AUTO_MIGRATION" = "1" ] || [ "$LARAVEL_AUTO_MIGRATION" = "true" ]; then
    if [ -f "$APP_PATH/artisan" ]; then
        LARAVEL_AUTO_MIGRATION_COMMAND="${LARAVEL_AUTO_MIGRATION_COMMAND:-"migrate"}"
        MIGRATION_CMD="php artisan $LARAVEL_AUTO_MIGRATION_COMMAND --force -n"

        if php artisan "$LARAVEL_AUTO_MIGRATION_COMMAND" --help | grep -qF -- '--isolated'; then
            MIGRATION_CMD="$MIGRATION_CMD --isolated"
        fi

        $MIGRATION_CMD $LARAVEL_AUTO_MIGRATION_OPTIONS || true
    fi
fi

# Link storage
if [ -f "$APP_PATH/artisan" ]; then
    php artisan storage:link || true
fi

# Configure Supervisor for Laravel Background Services
SUPERVISOR_CONF_DIR="/etc/supervisor/conf.d"
mkdir -p "$SUPERVISOR_CONF_DIR"

if [ "${LARAVEL_ENABLE_QUEUE_WORKER:-0}" = "1" ] || [ "$LARAVEL_ENABLE_QUEUE_WORKER" = "true" ]; then
    cat <<EOF > "$SUPERVISOR_CONF_DIR/queue_worker.conf"
[program:queue_worker]
command=php $APP_PATH/artisan ${LARAVEL_QUEUE_WORKER_COMMAND:-"queue:work"} $LARAVEL_QUEUE_WORKER_OPTIONS
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
autostart=true
autorestart=true
user=www-data
EOF
fi

if [ "${LARAVEL_ENABLE_SCHEDULER:-1}" = "1" ] || [ "$LARAVEL_ENABLE_SCHEDULER" = "true" ]; then
    cat <<EOF > "$SUPERVISOR_CONF_DIR/scheduler.conf"
[program:scheduler]
command=php $APP_PATH/artisan ${LARAVEL_SCHEDULER_COMMAND:-"schedule:work"} $LARAVEL_SCHEDULER_OPTIONS
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
autostart=true
autorestart=true
user=www-data
EOF
fi

if [ "${LARAVEL_ENABLE_HORIZON:-0}" = "1" ] || [ "$LARAVEL_ENABLE_HORIZON" = "true" ]; then
    cat <<EOF > "$SUPERVISOR_CONF_DIR/horizon.conf"
[program:horizon]
command=php $APP_PATH/artisan ${LARAVEL_HORIZON_COMMAND:-"horizon"} $LARAVEL_HORIZON_OPTIONS
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
autostart=true
autorestart=true
user=www-data
EOF
fi

if [ "${LARAVEL_ENABLE_PULSE:-0}" = "1" ] || [ "$LARAVEL_ENABLE_PULSE" = "true" ]; then
    cat <<EOF > "$SUPERVISOR_CONF_DIR/pulse.conf"
[program:pulse]
command=php $APP_PATH/artisan ${LARAVEL_PULSE_COMMAND:-"pulse:check"} $LARAVEL_PULSE_OPTIONS
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
autostart=true
autorestart=true
user=www-data
EOF
fi

if [ "${LARAVEL_ENABLE_REVERB:-0}" = "1" ] || [ "$LARAVEL_ENABLE_REVERB" = "true" ]; then
    # Add --debug flag if needed (omitted for simplicity, but can be added based on DEBUG env)
    cat <<EOF > "$SUPERVISOR_CONF_DIR/reverb.conf"
[program:reverb]
command=php $APP_PATH/artisan ${LARAVEL_REVERB_COMMAND:-"reverb:start"} $LARAVEL_REVERB_OPTIONS
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
autostart=true
autorestart=true
user=www-data
EOF
fi

# Execute CMD (usually supervisord)
exec "$@"
