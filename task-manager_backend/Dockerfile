FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    php8.3 php8.3-fpm php8.3-cli \
    php8.3-mysql php8.3-mbstring php8.3-xml php8.3-bcmath php8.3-gd \
    nginx curl zip unzip git supervisor \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled /var/log/supervisor
RUN printf 'server {\n    listen 80 default_server;\n    root /var/www/html/public;\n    index index.php;\n    location / {\n        try_files $uri $uri/ /index.php?$query_string;\n    }\n    location ~ \\.php$ {\n        include snippets/fastcgi-php.conf;\n        fastcgi_pass unix:/run/php/php8.3-fpm.sock;\n    }\n}\n' > /etc/nginx/sites-available/default && \
    ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

RUN printf '[supervisord]\nnodaemon=true\nlogfile=/var/log/supervisor/supervisord.log\n\n[program:php-fpm]\ncommand=php-fpm8.3 --nodaemonize\nautostart=true\nautorestart=true\nstderr_logfile=/var/log/supervisor/php-fpm.err.log\nstdout_logfile=/var/log/supervisor/php-fpm.out.log\n\n[program:nginx]\ncommand=/usr/sbin/nginx -g "daemon off;"\nautostart=true\nautorestart=true\nstderr_logfile=/var/log/supervisor/nginx.err.log\nstdout_logfile=/var/log/supervisor/nginx.out.log\n' > /etc/supervisor/conf.d/supervisord.conf

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/html
COPY . .

RUN mkdir -p bootstrap/cache storage/logs storage/framework/sessions storage/framework/views storage/framework/cache
RUN composer install 2>&1 | head -20 || true
RUN chown -R www-data:www-data . && chmod -R 777 bootstrap/cache storage

RUN printf '#!/bin/bash\necho "Setting permissions..."\nchown -R www-data:www-data /var/www/html\nchmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache\necho "Starting supervisor..."\nexec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf\n' > /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 80
CMD ["/entrypoint.sh"]
