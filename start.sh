#!/bin/bash

# Set essential variables
export APP_KEY="base64:***REMOVED***="
export APP_ENV="production" 
export APP_DEBUG="false"

# Clear all caches aggressively
php artisan config:clear
php artisan route:clear  
php artisan view:clear
php artisan cache:clear || true

# Cache only config (skip route cache to avoid conflicts)
php artisan config:cache

# Start server
php -S 0.0.0.0:$PORT -t public
