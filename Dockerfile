FROM php:8.1-cli-alpine

# Install system dependencies
RUN apk update && apk add --no-cache \
    postgresql-dev \
    zip \
    unzip \
    curl

# Install PHP extensions
RUN docker-php-ext-install pdo_pgsql

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /app

# Copy composer files first for better caching
COPY composer.json composer.lock ./

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Copy application files
COPY . .

# Set permissions
RUN chmod -R 755 storage bootstrap/cache

# Generate optimized autoloader
RUN composer dump-autoload --optimize

# Expose port
EXPOSE 8000

# Start the application
CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=8000
