# ==========================================
# Base Image
# ==========================================
FROM alpine:3.20

# ==========================================
# Install Apache, PHP 8.3 dan ekstensi Laravel
# ==========================================
RUN apk add --no-cache \
    apache2 \
    php83-apache2 \
    php83 \
    php83-phar \
    php83-iconv \
    php83-openssl \
    php83-pdo \
    php83-pdo_mysql \
    php83-pdo_sqlite \
    php83-sqlite3 \
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

# ==========================================
# Symlink PHP
# ==========================================
RUN ln -sf /usr/bin/php83 /usr/bin/php

# ==========================================
# Install Composer
# ==========================================
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# ==========================================
# Konfigurasi Apache
# ==========================================
RUN sed -i 's/Listen 80/Listen 7860/' /etc/apache2/httpd.conf && \
    sed -i 's#^DocumentRoot ".*#DocumentRoot "/var/www/localhost/htdocs/public"#' /etc/apache2/httpd.conf && \
    sed -i 's#Directory "/var/www/localhost/htdocs"#Directory "/var/www/localhost/htdocs/public"#' /etc/apache2/httpd.conf && \
    sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/httpd.conf && \
    sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/apache2/httpd.conf && \
    echo "LoadModule php_module /usr/lib/apache2/mod_php83.so" >> /etc/apache2/httpd.conf && \
    echo "AddHandler php-script .php" >> /etc/apache2/httpd.conf

# ==========================================
# Working Directory
# ==========================================
WORKDIR /var/www/localhost/htdocs

# ==========================================
# Copy Source Code
# ==========================================
COPY . .

# ==========================================
# Install Composer Dependency
# ==========================================
RUN composer install --no-dev --optimize-autoloader

RUN cp .env.example .env && \
    php artisan key:generate --force

# ==========================================
# Bersihkan Config Laravel
# (Tidak menjalankan cache:clear)
# ==========================================
RUN CACHE_STORE=array \
    SESSION_DRIVER=array \
    QUEUE_CONNECTION=sync \
    php artisan config:clear

# ==========================================
# Permission
# ==========================================
RUN mkdir -p storage/framework/cache/data && \
    mkdir -p storage/framework/sessions && \
    mkdir -p storage/framework/views && \
    chown -R apache:apache storage bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache

# ==========================================
# Environment
# ==========================================
ENV APP_ENV=production
ENV APP_DEBUG=true
ENV CACHE_STORE=file
ENV SESSION_DRIVER=file
ENV QUEUE_CONNECTION=sync

EXPOSE 7860

# ==========================================
# Start Apache
# ==========================================
CMD ["httpd", "-D", "FOREGROUND"]