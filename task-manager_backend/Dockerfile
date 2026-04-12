FROM php:8.3-apache

RUN apt-get update && apt-get install -y \
    git curl zip unzip \
    libonig-dev \
    libjpeg-dev libpng-dev libfreetype6-dev \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Remove ALL MPM modules completely, then enable only mpm_prefork
RUN rm -f /etc/apache2/mods-enabled/mpm_*.load /etc/apache2/mods-enabled/mpm_*.conf
RUN a2enmod mpm_prefork rewrite headers

# Create Apache VirtualHost config for Laravel public folder
RUN printf '<VirtualHost *:80>\n    DocumentRoot /var/www/html/public\n    <Directory /var/www/html/public>\n        AllowOverride All\n        Require all granted\n    </Directory>\n    ErrorLog ${APACHE_LOG_DIR}/error.log\n    CustomLog ${APACHE_LOG_DIR}/access.log combined\n</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/html
COPY . .

# Create necessary directories
RUN mkdir -p bootstrap/cache storage/logs storage/framework/sessions storage/framework/views storage/framework/cache

# Skip optimization - just install
RUN composer install 2>&1 | head -20 || true

RUN cp .env.example .env && php artisan key:generate 2>/dev/null || true
RUN chown -R www-data:www-data . && chmod -R 755 bootstrap/cache storage

EXPOSE 80
CMD ["apache2-foreground"]
