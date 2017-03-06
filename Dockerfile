FROM php:7.0.16-apache
MAINTAINER Attila Sumi sumia01@gmail.com

RUN apt-get update && \
    apt-get -y install curl git bzip2 openssh-client rsync --no-install-recommends zip unzip && \

    a2dismod mpm_event && \
    a2enmod mpm_prefork \
            rewrite \
            headers \
            deflate \
            env \
            expires \
            filter \
            ldap \
            vhost_alias \
            negotiation \
            mime \
            authnz_ldap \
            authz_core \
            authz_host \
            authz_user \
            session && \
    ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log && \
    cd /var  && \
    apt-get clean && rm -r /var/lib/apt/lists/*;

# install node, script from official node docker image, modified to use gz
# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
  && for key in \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done
ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 6.9.5
RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xzf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 --no-same-owner \
  && rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc SHASUMS256.txt
ADD https://www.npmjs.com/install.sh /tmp/nodeinstall.sh
RUN sh /tmp/nodeinstall.sh
RUN rm /tmp/nodeinstall.sh
RUN npm install -g yarn
# install composer
RUN php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === trim(file_get_contents('https://composer.github.io/installer.sig'))) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

RUN mkdir /home/www-data \
    && chown -R www-data:www-data /home/www-data \
    && chown -R www-data:www-data /var/www
WORKDIR /var/www/html

EXPOSE 80

CMD ["apache2-foreground"]