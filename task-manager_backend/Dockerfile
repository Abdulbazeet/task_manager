FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    mysql-client

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /app

# Copy existing application directory contents
COPY . .

# Install dependencies
RUN composer install --no-interaction --prefer-dist

# Copy .env.example to .env
RUN cp .env.example .env

# Generate application key
RUN php artisan key:generate

# Expose port 8000
EXPOSE 8000

# Create entrypoint script
RUN echo '#!/bin/bash\nphp artisan migrate --force\nphp artisan serve --host=0.0.0.0 --port=8000' > /app/start.sh
RUN chmod +x /app/start.sh

# Start Laravel server with migrations
CMD ["/app/start.sh"]
