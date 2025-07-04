FROM php:8.1-cli-alpine

# Install SQLite
RUN apk add --no-cache sqlite sqlite-dev
RUN docker-php-ext-install pdo_sqlite

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /app

# Copy composer files first for better caching
COPY composer.json composer.lock ./

# Install dependencies
RUN composer install --no-dev --optimize-autoloader --ignore-platform-reqs

# Copy application
COPY . .

# Create SQLite database
RUN touch database/database.sqlite
RUN chmod 666 database/database.sqlite

# Set permissions
RUN chmod -R 755 storage bootstrap/cache

EXPOSE 8000

CMD php artisan serve --host=0.0.0.0 --port=8000
