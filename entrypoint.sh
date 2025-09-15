#!/bin/sh
set -e

cd /var/www/html

# 1. Copy .env if missing
if [ ! -f .env ]; then
  echo "[entrypoint] .env not found, creating from .env.example"
  cp .env.example .env
fi

# 2. Laravel key generate (only if APP_KEY is empty)
if ! grep -q "^APP_KEY=" .env || grep -q "^APP_KEY=$" .env; then
  echo "[entrypoint] Generating app key..."
  php artisan key:generate --force
fi

# 3. Run migrations
echo "[entrypoint] Running migrations..."
php artisan migrate --force || true

# 4. Clear and cache config/routes/views (optional, safe in dev)
php artisan config:clear || true
php artisan cache:clear  || true
php artisan route:clear  || true
php artisan view:clear   || true

# Finally, exec the main container command (php-fpm)
exec "$@"

