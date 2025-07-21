#!/bin/bash

# Use Railway's environment variables only  
export APP_ENV="production"
export APP_DEBUG="false"

# Clear and cache config
php artisan config:clear
php artisan config:cache
php artisan route:clear

# Run database migrations
echo "Running database migrations..."
php artisan migrate --force

# Seed the database with AI Command Room data
echo "Seeding database with AI Command Room data..."
php artisan db:seed --class=AICommandRoomSeeder --force

# Start server
echo "Starting Laravel server..."
php -S 0.0.0.0:$PORT -t public
