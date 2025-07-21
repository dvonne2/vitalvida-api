#!/bin/bash
echo "=== FORCED REBUILD $(date) ==="

# Use Railway's environment variables only  
export APP_ENV="production"
export APP_DEBUG="false"

# Complete cache destruction
rm -rf bootstrap/cache/*.php || true
rm -rf storage/framework/cache/data/* || true
rm -rf storage/framework/sessions/* || true
rm -rf storage/framework/views/* || true
rm -rf storage/logs/*.log || true

# Clear ALL Laravel caches aggressively
php artisan config:clear || true
php artisan route:clear || true
php artisan cache:clear || true
php artisan view:clear || true
php artisan optimize:clear || true

# Force route registration
php artisan route:cache || true
php artisan config:cache || true

echo "=== STARTING SERVER ==="
php -S 0.0.0.0:$PORT -t public
