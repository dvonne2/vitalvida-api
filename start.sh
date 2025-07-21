#!/bin/bash
echo "=== Starting VitalVida API ==="

# Set environment
export APP_ENV="production"
export APP_DEBUG="false"

# AGGRESSIVE CACHE CLEARING
echo "=== Clearing all caches ==="
rm -rf bootstrap/cache/*.php || true
rm -rf storage/framework/cache/data/* || true
rm -rf storage/framework/sessions/* || true
rm -rf storage/framework/views/* || true

# Clear all Laravel caches
php artisan config:clear || true
php artisan route:clear || true
php artisan cache:clear || true
php artisan view:clear || true
php artisan optimize:clear || true

# Force route registration
echo "=== Forcing route registration ==="
php artisan route:cache || true
php artisan config:cache || true

echo "=== Server starting on port $PORT ==="
php -S 0.0.0.0:$PORT -t public
