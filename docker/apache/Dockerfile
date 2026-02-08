FROM httpd:2.4-bookworm

RUN set -eux; \
    sed -i \
      -e 's/^#LoadModule proxy_module/LoadModule proxy_module/' \
      -e 's/^#LoadModule proxy_fcgi_module/LoadModule proxy_fcgi_module/' \
      -e 's/^#LoadModule rewrite_module/LoadModule rewrite_module/' \
      -e 's|^DocumentRoot "/usr/local/apache2/htdocs"|DocumentRoot "/var/www/apache"|' \
      -e 's|<Directory "/usr/local/apache2/htdocs">|<Directory "/var/www/apache">|' \
      /usr/local/apache2/conf/httpd.conf; \
    echo "Include conf/extra/vhost.conf" >> /usr/local/apache2/conf/httpd.conf

COPY docker/apache/vhost.conf /usr/local/apache2/conf/extra/vhost.conf
