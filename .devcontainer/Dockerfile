FROM node:current-alpine as node
FROM composer:latest as composer

# Usa la imagen base de PHP
FROM php:8.4-fpm

# Instala herramientas y zsh con theme
RUN apt-get update && \
  apt-get install -y git curl wget gnupg2 lsb-release apt-transport-https ca-certificates unzip p7zip-full zsh && \
  apt-get clean

# Instala zsh con Spaceship y plugins
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.1/zsh-in-docker.sh)" -- \
    -t https://github.com/denysdovhan/spaceship-prompt \
    -a 'SPACESHIP_PROMPT_ADD_NEWLINE="false"' \
    -a 'SPACESHIP_PROMPT_SEPARATE_LINE="false"' \
    -p git \
    -p ssh-agent \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions

# Cambiar el shell por defecto para root (o para otro usuario si defines uno)
RUN chsh -s /bin/zsh root

# Instala extensiones necesarias
RUN docker-php-ext-install pdo pdo_mysql

RUN apt-get update && apt-get install -y libpq-dev \
  && docker-php-ext-install pdo_pgsql

RUN pecl install xdebug \
  && docker-php-ext-install pcntl \
  && docker-php-ext-enable xdebug

# Instala Node.js (en Alpine no aplica la línea de nodesource)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
  apt-get install -y nodejs && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Instala Laravel globalmente
RUN composer global require laravel/installer

# Copia config de Xdebug
COPY ./php/xdebug/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# Setea variable PATH para Composer global
ENV PATH="/root/.composer/vendor/bin:$PATH"

# Establece el directorio de trabajo
WORKDIR /usr/share/nginx/html
