FROM php:8.3-apache

RUN apt-get update && apt-get install -y \
    git curl zip unzip \
    liboniguruma-dev \
    libjpeg-dev libpng-dev libfreetype6-dev \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd
RUN a2enmod rewrite

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/html
COPY . .

# Skip optimization - just install
RUN composer install 2>&1 | head -20 || true

RUN cp .env.example .env && php artisan key:generate 2>/dev/null || true
RUN chown -R www-data:www-data . && find storage bootstrap/cache -type d -exec chmod 777 {} \;

RUN echo '<Directory /var/www/html/public>\nAllowOverride All\n</Directory>' >> /etc/apache2/apache2.conf
RUN sed -i 's|/var/www/html|/var/www/html/public|' /etc/apache2/sites-available/000-default.conf

EXPOSE 80
CMD ["apache2-foreground"]
