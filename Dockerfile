FROM php:8.3-apache

# Install ekstensi PHP untuk Laravel
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev zip unzip git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql gd

# Aktifkan rewrite untuk .htaccess Laravel
RUN a2enmod rewrite

# Ubah port Apache ke 7860 (Wajib untuk Hugging Face)
RUN sed -i 's/Listen 80/Listen 7860/' /etc/apache2/ports.conf
RUN sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:7860>/' /etc/apache2/sites-available/000-default.conf

# Set DocumentRoot ke folder public Laravel
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Copy project
WORKDIR /var/www/html
COPY . .

# Install Composer & atur permission
# GANTI DENGAN INI (Jauh lebih aman dari cache miss):
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"
RUN composer install --no-dev --optimize-autoloader
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 7860
CMD ["apache2-foreground"]