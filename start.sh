#!/bin/bash

# Copy production env file
cp .env.production .env

# Clear and rebuild Laravel caches
php artisan config:clear
php artisan config:cache
php artisan route:cache

# Start server
php -S 0.0.0.0:$PORT -t public
