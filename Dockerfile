FROM php:8.3-fpm-alpine

ARG COOLIFY_FQDN
ARG SERVICE_FQDN_PIWIGO_NGINX
ARG SERVICE_URL_PIWIGO_NGINX
ARG SERVICE_PASSWORD_MYSQLROOT
ARG SERVICE_USER_MYSQL
ARG SERVICE_PASSWORD_MYSQL
ARG TZ

# Runtime dependencies
RUN apk add --no-cache \
    nginx \
    supervisor \
    icu-libs \
    libzip \
    libpng \
    libwebp \
    freetype \
    libjpeg-turbo

# Build dependencies + PHP extensions
RUN apk add --no-cache --virtual .build-deps \
    freetype-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    icu-dev \
    libzip-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        mysqli \
        gd \
        exif \
        zip \
        opcache \
    && apk del .build-deps

RUN apk add --no-cache curl unzip

ENV PIWIGO_VERSION=16.4.0

WORKDIR /var/www/html

RUN curl -fsSL "https://piwigo.org/download/dlcounter.php?code=${PIWIGO_VERSION}" -o piwigo.zip \
    && unzip piwigo.zip \
    && rm piwigo.zip \
    && mv piwigo/* . \
    && mv piwigo/.* . 2>/dev/null || true \
    && rmdir piwigo \
    && mkdir -p _data/i local upload \
    && chown -R www-data:www-data /var/www/html

COPY nginx/php-fpm.conf /etc/php83/php-fpm.d/www.conf
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/piwigo-default.conf /etc/nginx/conf.d/default.conf
COPY supervisord.conf /etc/supervisord.conf
COPY entrypoint.sh /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]