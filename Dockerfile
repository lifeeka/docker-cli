FROM php:8.0.5-cli

ARG DEBIAN_FRONTEND=noninteractive

ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV TERM xterm

RUN apt-get update -y

RUN ln -snf /usr/share/zoneinfo/UTC /etc/localtime && echo UTC > /etc/timezone
RUN apt-get install -y software-properties-common

RUN apt-get update && apt-get install -y --fix-missing \
    apt-utils \
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
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash
RUN apt install nodejs -y

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update -y
RUN apt install yarn -y

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