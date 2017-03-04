FROM php:7.0.16-apache
MAINTAINER Attila Sumi sumia01@gmail.com

# Usage:
# docker run -d --name=apache-php -p 8080:80 -p 8443:443 chriswayg/apache-php
# webroot: /var/www/html/
# Apache2 config: /etc/apache2/

RUN apt-get update && \
    apt-get -y install curl && \

    a2dismod mpm_event && \
    a2enmod mpm_prefork \
            rewrite && \

    ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log && \
    cd /var  && \
    curl https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer  && \
    apt-get clean && rm -r /var/lib/apt/lists/*

WORKDIR /var/www/html

EXPOSE 80

CMD ["apache2-foreground"]