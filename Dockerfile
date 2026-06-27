# 1. Use the official lightweight Alpine base image
FROM alpine:3.20

# 2. Install Apache, PHP 8.3, and all Laravel-required extensions
RUN apk add --no-cache \
    apache2 \
    php83-apache2 \
    php83 \
    php83-phar \
    php83-iconv \
    php83-openssl \
    php83-pdo_mysql \
    php83-gd \
    php83-session \
    php83-fileinfo \
    php83-xml \
    php83-dom \
    php83-mbstring \
    php83-curl \
    php83-zip \
    php83-tokenizer \
    php83-xmlwriter \
    php83-simplexml \
    php83-xmlreader \
    php83-ctype \
    bash \
    curl \
    zip \
    unzip \
    git

# 3. Symlink php83 to php
RUN ln -sf /usr/bin/php83 /usr/bin/php

# 4. Copy Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 5. Configure Apache
RUN sed -i 's/Listen 80/Listen 7860/' /etc/apache2/httpd.conf && \
    sed -i 's#^DocumentRoot ".*#DocumentRoot "/var/www/localhost/htdocs/public"#' /etc/apache2/httpd.conf && \
    sed -i 's#Directory "/var/www/localhost/htdocs"#Directory "/var/www/localhost/htdocs/public"#' /etc/apache2/httpd.conf && \
    sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/httpd.conf && \
    sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/apache2/httpd.conf && \
    echo "LoadModule php_module /usr/lib/apache2/mod_php83.so" >> /etc/apache2/httpd.conf && \
    echo "AddHandler php-script .php" >> /etc/apache2/httpd.conf

# 6. Set working directory
WORKDIR /var/www/localhost/htdocs

# 7. Copy project files
COPY . .

# 8. Install dependencies FIRST
RUN composer install --no-dev --optimize-autoloader

# 9. Clear cache and config, bypassing the database connection requirements
RUN DB_CONNECTION=sqlite DB_DATABASE=/dev/null CACHE_DRIVER=array php artisan config:clear && \
    DB_CONNECTION=sqlite DB_DATABASE=/dev/null CACHE_DRIVER=array php artisan cache:clear

# 10. Fix permissions
RUN chown -R apache:apache /var/www/localhost/htdocs/storage /var/www/localhost/htdocs/bootstrap/cache

EXPOSE 7860
ENV APP_DEBUG=true

CMD ["httpd", "-D", "FOREGROUND"]