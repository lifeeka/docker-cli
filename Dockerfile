FROM php:8.0.5-cli
LABEL maintainer=spmsupun@gmail.com

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y

RUN ln -snf /usr/share/zoneinfo/UTC /etc/localtime && echo UTC > /etc/timezone
RUN apt-get install -y software-properties-common

RUN apt-get update && apt-get install -y --fix-missing \
    apt-utils \
    procps \
    gnupg

RUN echo "deb http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list
RUN echo "deb-src http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list
RUN curl -sS --insecure https://www.dotdeb.org/dotdeb.gpg | apt-key add -

RUN apt-get update && apt-get install -y \
    zlib1g-dev \
    libzip-dev
RUN docker-php-ext-install zip mysqli pdo pdo_mysql && docker-php-ext-enable pdo_mysql

#####################################
# YARN NPM
#####################################
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash
RUN apt install nodejs -y

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update -y
RUN apt install yarn -y
RUN yarn config set network-timeout 600000 -g

#####################################
# Composer:
#####################################

# Install composer and add its bin to the PATH.
RUN curl -s http://getcomposer.org/installer | php && \
    echo "export PATH=${PATH}:/var/www/vendor/bin" >> ~/.bashrc && \
    mv composer.phar /usr/local/bin/composer

RUN composer global require "squizlabs/php_codesniffer=*"
RUN composer global require "friendsofphp/php-cs-fixer=*"
RUN echo 'export PATH="$PATH:$HOME/.config/composer/vendor/bin"' >> ~/.bashrc

RUN npm install -g @nestjs/cli
RUN npm install -g typeorm
RUN npm install -g ts-node

#####################################
# NestJs:
#####################################
RUN npm install -g next

#####################################
# Python
#####################################
RUN apt install -y python musl-dev
RUN ln -s /usr/lib/x86_64-linux-musl/libc.so /lib/libc.musl-x86_64.so.1

#####################################
# Clean up
#####################################
RUN apt-get autoremove -y; \
    apt-get clean; \
    rm -rf \
        /var/cache/apt/archives \
        /var/cache/ldconfig/* \
        /var/lib/apt/lists/* \
        /var/log/alternatives.log \
        /var/log/apt/* \
        /var/log/dpkg.log
#####################################
# Mongo CLI
#####################################
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
RUN echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" |   tee /etc/apt/sources.list.d/mongodb-org-4.0.list
RUN apt-get update && apt-get install -y mongodb-org-shell

WORKDIR /app
