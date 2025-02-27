FROM node:current-alpine as node
FROM composer:latest as composer

# Usa la imagen base de PHP
FROM php:8.4-fpm

# Instala extensiones necesarias
RUN docker-php-ext-install pdo pdo_mysql

RUN apt-get update && apt-get install -y libpq-dev \
  && docker-php-ext-install pdo pdo_pgsql

RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y git

RUN apt-get update && \
  apt-get install -y --no-install-recommends p7zip-full && \
  apt-get install zip unzip && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  7z -h

ENV PATH="/root/.composer/vendor/bin:$PATH"

# Instala nodejs
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
  apt-get install -y nodejs && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Instala Composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Expone las dependencias globales
RUN composer global require laravel/installer

# Establece el directorio de trabajo
WORKDIR /usr/share/nginx/html
