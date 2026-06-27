FROM php:8.3-apache

# 1. Install utilitas dasar yang dibutuhkan oleh Composer
RUN apt-get update && apt-get install -y zip unzip git

# 2. Install ekstensi GD & PDO_MYSQL secara instan tanpa kompilasi berat (Mencegah OOM/Timeout di Hugging Face)
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions gd pdo_mysql

# 3. Aktifkan rewrite untuk .htaccess Laravel
RUN a2enmod rewrite

# 4. Ubah port Apache ke 7860 (Wajib untuk Hugging Face)
RUN sed -i 's/Listen 80/Listen 7860/' /etc/apache2/ports.conf
RUN sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:7860>/' /etc/apache2/sites-available/000-default.conf

# 5. Set DocumentRoot ke folder public Laravel
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 6. Set Working Directory
WORKDIR /var/www/html

# 7. Install Composer langsung menggunakan skrip PHP resmi (Aman dari cache miss Docker Hub)
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

# 8. Copy seluruh source code project Laravel ke dalam container
COPY . .

# 9. Jalankan installasi dependency Laravel & atur permission folder
RUN composer install --no-dev --optimize-autoloader
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 7860
CMD ["apache2-foreground"]