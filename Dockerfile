# Use ultra-lightweight PHP 8.3 Alpine image with Apache
FROM php:8.3-alpine-apache

# 1. Install system utilities and PHP extensions via Alpine binaries (ZERO compiling!)
RUN apk add --no-cache \
    bash \
    curl \
    zip \
    unzip \
    git \
    libpng \
    libjpeg-turbo \
    freetype \
    php83-pdo_mysql \
    php83-gd \
    php83-session \
    php83-fileinfo \
    php83-xml \
    php83-dom \
    php83-mbstring

# 2. Copy official pre-compiled Composer binary
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 3. Enable Apache Rewrite module
RUN sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/apache2/httpd.conf

# 4. Change Apache port to 7860 (Mandatory for Hugging Face Spaces)
RUN sed -i 's/Listen 80/Listen 7860/' /etc/apache2/httpd.conf

# 5. Point Apache DocumentRoot to Laravel's public directory
ENV APACHE_DOCUMENT_ROOT=/var/www/localhost/htdocs/public
RUN sed -i 's!/var/www/localhost/htdocs!/var/www/localhost/htdocs/public!g' /etc/apache2/httpd.conf

# 6. Set working directory
WORKDIR /var/www/localhost/htdocs

# 7. Copy your Laravel project files
COPY . .

# 8. Install PHP dependencies and set correct permissions for Alpine's 'apache' user
RUN composer install --no-dev --optimize-autoloader \
    && chown -R apache:apache /var/www/localhost/htdocs/storage /var/www/localhost/htdocs/bootstrap/cache

EXPOSE 7860

# Start Apache in foreground
CMD ["httpd", "-D", "FOREGROUND"]