ARG PHP_IMAGE=php:8.2-fpm-bookworm

FROM ${PHP_IMAGE} AS build_ext

ARG INSTALL_XDEBUG=true

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      libzip-dev zlib1g-dev libpq-dev \
      libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
      libicu-dev libonig-dev \
      $PHPIZE_DEPS; \
    docker-php-ext-configure zip; \
    docker-php-ext-configure gd --with-freetype --with-jpeg; \
    docker-php-ext-install -j"$(nproc)" \
      pdo pdo_mysql pdo_pgsql \
      zip gd intl pcntl opcache mbstring sockets; \
    pecl install redis; \
    docker-php-ext-enable redis; \
    if [ "$INSTALL_XDEBUG" = "true" ]; then \
      pecl install xdebug; \
      docker-php-ext-enable xdebug; \
    fi; \
    rm -rf /tmp/pear /var/lib/apt/lists/*

FROM node:22-bookworm-slim AS node_runtime

FROM ${PHP_IMAGE} AS runtime

ARG INSTALL_XDEBUG=true
ARG INSTALL_BROWSER_TOOLS=false
ARG INSTALL_PUPPETEER=false

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME=/root/.composer \
    PATH="/root/.composer/vendor/bin:${PATH}" \
    SHELL=/bin/zsh \
    PUPPETEER_SKIP_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium \
    BROWSERSHOT_CHROME_PATH=/usr/bin/chromium \
    BROWSERSHOT_NODE_PATH=/usr/local/bin/node \
    BROWSERSHOT_NPM_PATH=/usr/local/bin/npm

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      git curl ca-certificates unzip zip p7zip-full wget \
      zsh openssh-client \
      libzip4 zlib1g libpq5 \
      libfreetype6 libjpeg62-turbo libpng16-16 libicu72 libonig5; \
    if [ "$INSTALL_BROWSER_TOOLS" = "true" ]; then \
      apt-get install -y --no-install-recommends \
        chromium \
        fonts-dejavu-core \
        fonts-noto-color-emoji \
        libnss3 \
        libxss1 \
        libasound2 \
        libatk-bridge2.0-0 \
        libgtk-3-0; \
    fi; \
    chsh -s /bin/zsh root; \
    rm -rf /var/lib/apt/lists/*

COPY --from=build_ext /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=build_ext /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/
COPY --from=node_runtime /usr/local/bin/node /usr/local/bin/node
COPY --from=node_runtime /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN set -eux; \
    ln -sf ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm; \
    ln -sf ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx; \
    ln -sf /usr/local/bin/node /usr/bin/node; \
    ln -sf /usr/local/bin/npm /usr/bin/npm; \
    ln -sf /usr/local/bin/npx /usr/bin/npx
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

COPY docker/php/common/shell/.zshrc /root/.zshrc
COPY docker/php/8.2/php.ini /usr/local/etc/php/php.ini
COPY docker/php/8.2/xdebug.ini /tmp/xdebug.ini

RUN set -eux; \
    if [ "$INSTALL_XDEBUG" = "true" ]; then \
      cp /tmp/xdebug.ini /usr/local/etc/php/conf.d/zz-xdebug.ini; \
    fi; \
    rm -f /tmp/xdebug.ini; \
    composer --version; \
    composer global require --no-interaction --no-progress laravel/installer:^5; \
    if [ "$INSTALL_PUPPETEER" = "true" ]; then \
      npm install -g puppeteer; \
      npm cache clean --force; \
    fi

WORKDIR /var/www
EXPOSE 9000 9003

CMD ["php-fpm"]
