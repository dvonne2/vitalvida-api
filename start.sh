#!/bin/bash

# Set environment variables directly
export APP_KEY="base64:***REMOVED***="
export APP_ENV="production"
export APP_DEBUG="false"
export DB_CONNECTION="pgsql"

# Clear and rebuild Laravel caches
php artisan config:clear
php artisan config:cache
php artisan route:cache

# Start server
php -S 0.0.0.0:$PORT -t public
