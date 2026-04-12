FROM php:8.3-apache

RUN apt-get update && apt-get install -y \
    git curl zip unzip \
    libonig-dev \
    libjpeg-dev libpng-dev libfreetype6-dev \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Completely disable event and worker MPM before enabling prefork
RUN a2dismod mpm_event mpm_worker 2>/dev/null || true
RUN a2enmod mpm_prefork rewrite

# Configure Apache for Laravel
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' /etc/apache2/sites-available/000-default.conf
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/c\
    <Directory /var/www/html/public>\
        AllowOverride All\
        Require all granted\
        <IfModule mod_rewrite.c>\
            RewriteEngine On\
            RewriteBase /\
            RewriteCond %{REQUEST_FILENAME} !-f\
            RewriteCond %{REQUEST_FILENAME} !-d\
            RewriteRule ^(.*)$ index.php/$1 [L]\
        </IfModule>\
    </Directory>' /etc/apache2/apache2.conf

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
