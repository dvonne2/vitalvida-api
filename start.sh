#!/bin/bash

# Use Railway's environment variables only  
export APP_ENV="production"
export APP_DEBUG="false"

# NUCLEAR CACHE CLEAR - Remove all cached files
rm -rf bootstrap/cache/*.php
rm -rf storage/framework/cache/data/*
rm -rf storage/framework/sessions/*
rm -rf storage/framework/views/*

# Clear all Laravel caches
php artisan config:clear
php artisan route:clear
php artisan cache:clear || true
php artisan view:clear || true
php artisan optimize:clear || true

# Fresh cache generation
php artisan config:cache

# Start server
php -S 0.0.0.0:$PORT -t public
