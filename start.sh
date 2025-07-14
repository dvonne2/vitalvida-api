#!/bin/bash

# Use Railway's environment variables only  
export APP_ENV="production"
export APP_DEBUG="false"

# Clear and cache config
php artisan config:clear
php artisan config:cache

# Start server
php -S 0.0.0.0:$PORT -t public
