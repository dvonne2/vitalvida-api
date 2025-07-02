FROM php:8.1-cli-alpine

# Install PostgreSQL
RUN apk add --no-cache postgresql-dev && docker-php-ext-install pdo_pgsql

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . .

# Skip problematic dependencies
RUN composer install --no-dev --ignore-platform-reqs --no-scripts

# Create SQLite database for simplicity
RUN touch database/database.sqlite

# Use SQLite instead of PostgreSQL for now
ENV DB_CONNECTION=sqlite
ENV DB_DATABASE=/app/database/database.sqlite

EXPOSE 8000

CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=8000
