FROM php:8.2-cli
WORKDIR /app
COPY . .
RUN apt-get update && apt-get install -y zip unzip git
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader
EXPOSE 8080
CMD ["php", "-S", "0.0.0.0:8080", "-t", "public"]
