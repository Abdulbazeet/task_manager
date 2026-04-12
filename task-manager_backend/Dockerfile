FROM php:8.3-apache

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

# Move to public folder as document root
RUN a2dissite 000-default.conf && \
    echo '<VirtualHost *:80>\n    ServerName localhost\n    DocumentRoot /var/www/html/public\n    <Directory /var/www/html/public>\n        AllowOverride All\n    </Directory>\n</VirtualHost>' > /etc/apache2/sites-available/default.conf && \
    a2ensite default.conf

EXPOSE 80

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
