FROM openjdk:8
MAINTAINER Cory Collier <cory.collier@ahss.org>

ENV ANT_VERSION 1.9.6
ENV PHP_VERSION=5.3.29
ENV PHP_FILENAME=php-5.3.29.tar.gz
ENV PHP_INI_DIR=/etc

RUN apt update -y

RUN apt install -y build-essential \
    autoconf \
    freetds-bin \
    freetds-common \
    git \
    ldap-utils \
    libbz2-dev \
    libcurl4-openssl-dev \
    libedit-dev \
    libssl-dev \
    libjpeg-dev \
    libjpeg62-turbo \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libpng-tools \
    libtidy-dev \
    libreadline-dev \
    libxml2 \
    libxml2-dev \
    libxslt1-dev \
    libxslt1.1 \
    mysql-client \
    readline-common \
    tidy \
    vim \
    zlib1g \
    zlib1g-dev

RUN cd /tmp \
    && git clone git://git.openssl.org/openssl.git \
    && cd openssl \
    && git checkout OpenSSL_1_0_2 \
    && ./config --prefix=/usr \
    && make \
    && make test \
    && make install

RUN ln -s /usr/include/x86_64-linux-gnu/openssl/ /usr/include/openssl
RUN ln -s /usr/include/x86_64-linux-gnu/curl/ /usr/include/curl

RUN set -xe \
    && cd /tmp \
    && curl -fSL "http://php.net/get/$PHP_FILENAME/from/this/mirror" -o "$PHP_FILENAME" \
    && mkdir -p /usr/src/php \
    && tar -xf "$PHP_FILENAME" -C /usr/src/php --strip-components=1 \
    && rm "$PHP_FILENAME" \
    && cd /usr/src/php \
    && ./configure \
      --with-libdir="/lib/x86_64-linux-gnu/" \
      --with-config-file-path="$PHP_INI_DIR" \
      --with-config-file-scan-dir="$PHP_INI_DIR/php.d" \
      --with-fpm-user=nginx \
      --with-fpm-group=nginx \
      --disable-cgi \
      --with-mysql \
      --enable-mysqlnd \
      --with-mysql=mysqlnd \
      --with-curl \
      --with-libedit \
      --with-zlib \
      --with-mcrypt \
      --with-mhash \
      --enable-mbstring \
      --with-gettext \
      --enable-ftp \
      --enable-zip \
      --enable-soap \
      --enable-bcmath \
      --with-xmlrpc \
      --with-tidy \
      --with-png-dir \
      --with-jpeg-dir \
      --with-bz2 \
      --with-zlib \
      --with-pear \
      --with-kerberos \
      --with-xsl \
      --with-gd \
      --enable-gd-native-ttf \
      --with-pcre-regex \
      --with-pdo-mysql=mysqlnd \
    && make \
    && make install \
    && make clean


RUN mkdir -p $PHP_INI_DIR/php.d
COPY config/php-settings.ini /$PHP_INI_DIR/php.d/custom.ini

RUN cd /tmp \
    && git clone git://github.com/xdebug/xdebug.git \
    && cd xdebug \
    && git checkout XDEBUG_2_2_7 \
    && phpize \
    && ./configure --enable-xdebug \
    && make \
    && make install

RUN cd && \
    wget -q http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz && \
    tar -xzf apache-ant-${ANT_VERSION}-bin.tar.gz && \
    mv apache-ant-${ANT_VERSION} /opt/ant && \
    rm apache-ant-${ANT_VERSION}-bin.tar.gz

# Install composer
# RUN php -r "readfile('http://getcomposer.org/installer');" > composer-setup.php \
#     && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
#     && php -r "unlink('composer-setup.php');"
#
ENV ANT_HOME /opt/ant
ENV PATH ${PATH}:/opt/ant/bin
