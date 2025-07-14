#!/bin/bash

# Copy production env file
cp .env.production .env

# Set environment variables directly as backup
export APP_KEY="base64:***REMOVED***="
export APP_ENV="production"
export APP_DEBUG="false"

# Clear ALL caches completely
php artisan config:clear
php artisan route:clear
php artisan cache:clear
php artisan view:clear

# Generate fresh autoloader
composer dump-autoload

# Cache only config (don't cache routes yet)
php artisan config:cache

# Start server
php -S 0.0.0.0:$PORT -t public
