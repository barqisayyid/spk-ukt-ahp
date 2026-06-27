# Menggunakan image PHP 8.3 + Apache yang sudah terinstall GD, PDO_MYSQL, dan Composer secara bawaan
FROM shinsenter/php:8.3-apache

# 1. Install utilitas dasar tambahan (Sangat cepat & ringan)
USER root
RUN apt-get update && apt-get install -y zip unzip git && rm -rf /var/lib/apt/lists/*

# 2. Ubah port Apache ke 7860 (Wajib untuk Hugging Face)
RUN sed -i 's/Listen 80/Listen 7860/' /etc/apache2/ports.conf
RUN sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:7860>/' /etc/apache2/sites-available/000-default.conf

# 3. Set DocumentRoot ke folder public Laravel
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# 4. Set Working Directory
WORKDIR /var/www/html

# 5. Copy seluruh source code project Laravel ke dalam container
COPY . .

# 6. Jalankan instalasi dependency Laravel & atur permission folder
# (Composer sudah tersedia langsung di dalam image ini)
RUN composer install --no-dev --optimize-autoloader
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

EXPOSE 7860
CMD ["apache2-foreground"]