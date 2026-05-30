FROM php:8.3-fpm-alpine

RUN apk add --no-cache \
    nginx \
    supervisor \
    libzip \
    libpng \
    libwebp \
    freetype \
    libjpeg-turbo \
    icu \
    exif \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        mysqli \
        gd \
        exif \
        zip \
        opcache

RUN apk add --no-cache curl unzip

ENV PIWIGO_VERSION=16.4.0

WORKDIR /var/www/html

RUN curl -fsSL "https://github.com/Piwigo/Piwigo/releases/download/${PIWIGO_VERSION}/Piwigo-${PIWIGO_VERSION}.zip" -o piwigo.zip \
    && unzip piwigo.zip \
    && rm piwigo.zip \
    && mkdir -p _data/i local upload \
    && chown -R www-data:www-data /var/www/html \
    && apk del curl unzip

COPY nginx/php-fpm.conf /etc/php83/php-fpm.d/www.conf
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisord.conf

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
