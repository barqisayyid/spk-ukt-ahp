# Menggunakan PHP 8.3 dengan pelayan web Apache berbasis Alpine (Sangat ringan)
FROM php:8.3-alpine-apache

# 1. Install ekstensi PHP & utilitas langsung dari paket biner Alpine (Nol Kompilasi!)
RUN apk add --no-cache \
    zip \
    unzip \
    git \
    php83-pecl-amqp \
    php83-pdo_mysql \
    php83-gd

# 2. Salin biner Composer resmi yang sudah matang
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 3. Aktifkan modul Apache Rewrite (Cara Alpine)
RUN sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/' /etc/apache2/httpd.conf

# 4. Ubah port Apache ke 7860 (Wajib untuk Hugging Face)
RUN sed -i 's/Listen 80/Listen 7860/' /etc/apache2/httpd.conf

# 5. Atur DocumentRoot Apache ke folder public Laravel
ENV APACHE_DOCUMENT_ROOT /var/www/localhost/htdocs/public
RUN sed -i 's!/var/www/localhost/htdocs!/var/www/localhost/htdocs/public!g' /etc/apache2/httpd.conf

# 6. Set Working Directory sesuai standar Alpine
WORKDIR /var/www/localhost/htdocs

# 7. Copy seluruh source code project Laravel
COPY . .

# 8. Jalankan instalasi dependency Laravel & atur hak akses file
RUN composer install --no-dev --optimize-autoloader
RUN chown -R apache:apache /var/www/localhost/htdocs/storage /var/www/localhost/htdocs/bootstrap/cache

EXPOSE 7860

# Jalankan Apache di foreground (Sesuai konfigurasi Alpine)
CMD ["httpd", "-D", "FOREGROUND"]