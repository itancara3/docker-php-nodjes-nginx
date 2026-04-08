# =============================
# Stage 1: Base (PHP + sistema)
# =============================
FROM php:8.3.6-fpm-bullseye AS base

ARG INSTALL_XDEBUG=true

ENV COMPOSER_ALLOW_SUPERUSER=1 \
  COMPOSER_HOME=/root/.composer \
  PATH="/root/.composer/vendor/bin:${PATH}" \
  SHELL=/bin/zsh \
  DEBIAN_FRONTEND=noninteractive

# --- System & PHP deps ---
RUN apt-get update && apt-get install -y openssh-client && apt-get install -y nano && apt-get install -y --no-install-recommends \
  git curl unzip zip gnupg2 wget sudo \
  zlib1g-dev libzip-dev libonig-dev libpq-dev \
  libpng-dev libjpeg-dev libfreetype6-dev libicu-dev \
  ca-certificates gnupg software-properties-common zsh bash \
  chromium fonts-dejavu fonts-noto-color-emoji \
  libx11-dev libx11-xcb1 libxcb1 libxcomposite1 libxcursor1 libxdamage1 libxi6 libxtst6 libnss3 \
  libxrandr2 libasound2 libpangocairo-1.0-0 libatk1.0-0 libcups2 libdrm2 libgbm1 libxss1 libgtk-3-0 \
  && rm -rf /var/lib/apt/lists/*

# --- Install Node.js 20.x ---
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y nodejs \
  && node -v && npm -v

# --- PHP extensions ---
RUN docker-php-ext-configure zip \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j"$(nproc)" \
  pdo pdo_mysql pdo_pgsql \
  zip gd intl pcntl opcache mbstring sockets

# --- PECL: Xdebug & Redis ---
RUN apt-get update && apt-get install -y --no-install-recommends $PHPIZE_DEPS \
  && if [ "$INSTALL_XDEBUG" = "true" ]; then \
  pecl install xdebug && docker-php-ext-enable xdebug; \
  fi \
  && pecl install redis && docker-php-ext-enable redis \
  && apt-get purge -y --auto-remove $PHPIZE_DEPS \
  && rm -rf /tmp/pear /var/lib/apt/lists/*

# =============================
# Stage 2: Final (tools + configs)
# =============================
FROM base AS final

# --- Composer ---
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

# --- Laravel installer ---
RUN composer global require --no-interaction --no-progress laravel/installer:^5 \
  && composer clear-cache

# --- Puppeteer (sin Chromium) ---
ENV PUPPETEER_SKIP_DOWNLOAD=true

RUN npm install -g puppeteer && npm cache clean --force

# --- Puppeteer/Browsershot config paths ---
ENV BROWSERSHOT_CHROME_PATH=/usr/bin/chromium \
  BROWSERSHOT_NODE_PATH=/usr/bin/node \
  BROWSERSHOT_NPM_PATH=/usr/bin/npm

# --- PHP & Zsh Configs ---
COPY ./php/php.ini /usr/local/etc/php/php.ini
COPY ./php/xdebug/xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
COPY ./shell/.zshrc /root/.zshrc

# --- Git Config (útil en devcontainer/Windsurf) ---
RUN git config --global user.email "ivan@pull.srl" \
  && git config --global user.name "Ivan Tancara" \
  && git config --global pull.rebase false

# --- Workdir / Ports / CMD ---
# WORKDIR /var/www/html
EXPOSE 9000

CMD ["php-fpm"]
