FROM php:8.2-apache

# Install required PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Get Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy files
COPY . .

# Install dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Generate key
RUN php artisan key:generate

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html

# Enable Apache rewrite module
RUN a2enmod rewrite

# Apache config
RUN echo "
<Directory /var/www/html>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>
" > /etc/apache2/conf-available/laravel.conf && a2enconf laravel

EXPOSE 80

# Create entrypoint script
RUN echo '#!/bin/bash\nphp artisan migrate --force\napache2-foreground' > /app/start.sh
RUN chmod +x /app/start.sh

CMD ["/app/start.sh"]
