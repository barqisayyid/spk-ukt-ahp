# 1. Use the official lightweight Alpine base image
FROM alpine:3.20

# 2. Install Apache, PHP 8.3, and all Laravel-required extensions natively
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

# 3. Symlink php83 to php so Composer and Artisan commands work seamlessly
RUN ln -sf /usr/bin/php83 /usr/bin/php

# 4. Copy official pre-compiled Composer binary
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 5. Configure Apache for Hugging Face (Port 7860) and Laravel (Public directory & Rewrites)
RUN sed -i 's/Listen 80/Listen 7860/' /etc/apache2/httpd.conf && \
    sed -i 's#^DocumentRoot ".*#DocumentRoot "/var/www/localhost/htdocs/public"#' /etc/apache2/httpd.conf && \
    sed -i 's#Directory "/var/www/localhost/htdocs"#Directory "/var/www/localhost/htdocs/public"#' /etc/apache2/httpd.conf && \
    sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/httpd.conf && \
    sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/apache2/httpd.conf

# 6. Set working directory
WORKDIR /var/www/localhost/htdocs

# 7. Copy your Laravel project files
COPY . .

# 8. Install PHP dependencies and set correct permissions for Alpine's 'apache' user
RUN composer install --no-dev --optimize-autoloader \
    && chown -R apache:apache /var/www/localhost/htdocs/storage /var/www/localhost/htdocs/bootstrap/cache

# Expose the mandatory Hugging Face port
EXPOSE 7860

# Start Apache in the foreground
CMD ["httpd", "-D", "FOREGROUND"]