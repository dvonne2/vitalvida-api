#!/bin/bash

# DON'T override Railway's injected environment variables
# cp .env.production .env  <- REMOVE THIS LINE

# Set only the essential variables that might be missing
export APP_KEY="base64:***REMOVED***="
export APP_ENV="production"
export APP_DEBUG="false"

# Clear and cache config (uses Railway's DB vars)
php artisan config:clear
php artisan config:cache

# Start server
php -S 0.0.0.0:$PORT -t public
