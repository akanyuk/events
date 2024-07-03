FROM php:7.4-fpm

RUN apt-get update

# common
RUN apt-get install -y apt-utils libssl-dev libzip-dev libonig-dev
RUN docker-php-ext-install iconv mbstring zip bcmath

# GD
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# cURL
RUN apt-get install -y libcurl3-dev
RUN docker-php-ext-install curl

# MySQL
RUN docker-php-ext-install mysqli pdo_mysql

# apcu
RUN pecl install apcu && docker-php-ext-enable apcu
