# =============================
# PHP 8.4 FPM (Alpine) + Node + Composer + Zsh + Laravel
# =============================

FROM php:8.4-fpm-alpine

ARG INSTALL_XDEBUG=true

ENV COMPOSER_ALLOW_SUPERUSER=1 \
  COMPOSER_HOME=/root/.composer \
  PATH="/root/.composer/vendor/bin:${PATH}" \
  SHELL=/bin/zsh

# --- System packages & PHP extensions ---
RUN set -eux; \
  apk add --no-cache \
  git curl ca-certificates gnupg unzip zip p7zip wget \
  libzip-dev zlib-dev postgresql-dev \
  freetype-dev libjpeg-turbo-dev libpng-dev \
  icu-dev openssh-client \
  oniguruma-dev \
  nodejs npm zsh \
  libfaketime; \
  \
  # Headers de kernel NECESARIOS para compilar ext/sockets en Alpine
  apk add --no-cache --virtual .kernel-headers linux-headers; \
  \
  docker-php-ext-configure zip; \
  docker-php-ext-configure gd --with-freetype --with-jpeg; \
  docker-php-ext-install -j"$(nproc)" \
  pdo pdo_mysql pdo_pgsql \
  zip gd intl pcntl opcache mbstring \
  sockets; \
  \
  # PECL (con toolchain) y limpieza
  apk add --no-cache --virtual .build-deps $PHPIZE_DEPS; \
  if [ "$INSTALL_XDEBUG" = "true" ]; then \
  pecl install xdebug; \
  docker-php-ext-enable xdebug; \
  fi; \
  pecl install redis; \
  docker-php-ext-enable redis; \
  rm -rf /tmp/pear; \
  apk del .build-deps .kernel-headers; \
  \
  # Zsh por defecto
  sed -i 's#/bin/ash#/bin/zsh#' /etc/passwd

# --- Composer from official image ---
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

# --- Laravel installer (global) ---
RUN set -eux; \
  composer --version; \
  composer global require --no-interaction --no-progress laravel/installer:^5

# --- PHP & Zsh configs ---
COPY ./php/php.ini /usr/local/etc/php/php.ini
COPY ./php/xdebug/xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
COPY ./shell/.zshrc /root/.zshrc

# =============================
# 👇 BROWSERSHOT / PUPPETEER
# =============================

# 1) Chromium + fuentes (ya lo tenías bien)
RUN set -eux; \
  apk add --no-cache \
  chromium \
  nss \
  harfbuzz \
  freetype \
  ttf-freefont \
  font-noto-emoji; \
  # En Alpine el binario puede ser /usr/bin/chromium o /usr/bin/chromium-browser
  if [ ! -x /usr/bin/chromium ]; then ln -s /usr/bin/chromium /usr/bin/chromium; fi

# 2) Forzar a Puppeteer a NO descargar Chrome y a usar el Chromium del sistema
ENV PUPPETEER_SKIP_DOWNLOAD=true \
  PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

# 3) Instalar Puppeteer DENTRO del contenedor (no en tu Mac)
RUN set -eux; \
  npm install -g puppeteer; \
  npm cache clean --force

# 4) Rutas para Browsershot (opcional, pero muy útil)
ENV BROWSERSHOT_CHROME_PATH=/usr/bin/chromium \
  BROWSERSHOT_NODE_PATH=/usr/bin/node \
  BROWSERSHOT_NPM_PATH=/usr/bin/npm

# --- Workdir / Expose / CMD ---
WORKDIR /var/www/html
EXPOSE 9000

# ENV LD_PRELOAD=/usr/lib/faketime/libfaketime.so.1
# ENV FAKETIME="@2025-01-01 15:30:00"

# RUN export FAKETIME="@2025-01-01 15:30:00"

CMD ["php-fpm"]
