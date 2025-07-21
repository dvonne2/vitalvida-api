#!/bin/bash
echo "=== Starting VitalVida API ==="

# Set environment
export APP_ENV="production"
export APP_DEBUG="false"

# Clear caches safely
php artisan config:clear || true
php artisan route:clear || true

# Cache config only (skip problematic caches)
php artisan config:cache || true

echo "=== Server starting on port $PORT ==="
php -S 0.0.0.0:$PORT -t public
