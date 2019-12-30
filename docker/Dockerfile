# Righteous Sandbox
#
# This is a crude containerized build tool that moots the need to
# install things like Node, PHPUnit, etc., locally.
#
# BUILD:
# docker build -t righteous/sandbox:latest -f Dockerfile .
#
# RUN:
# docker run --rm -v $PWD:/share -it --name righteous righteous/sandbox

FROM debian:buster-slim

# Labels
LABEL Name="Righteous Sandbox"
LABEL Version="20191229"

ENV righteous_init=""

# Run various APT operations.
RUN set -eux; \
	apt-get update \
	&& apt-get install -y --no-install-recommends \
		apt-transport-https \
		aria2 \
		bash-completion \
		curl \
		gnupg \
		locales \
		software-properties-common \
		wget \
	&& sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
	&& locale-gen \
	&& wget -q -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
	&& wget -q -O - https://apt.blobfolio.com/public.gpg.key | apt-key add - \
	&& wget -q -O - https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
	&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A2166B8DE8BDC3367D1901C11EE2FF37CA8DA16B \
	\
	&& echo deb http://ftp.us.debian.org/debian/ buster main > /etc/apt/sources.list \
	&& echo deb-src http://ftp.us.debian.org/debian/ buster main >> /etc/apt/sources.list \
	&& echo deb http://security.debian.org/ buster/updates main >> /etc/apt/sources.list \
	&& echo deb-src http://security.debian.org/ buster/updates main >> /etc/apt/sources.list \
	&& echo deb http://ftp.us.debian.org/debian/ buster-updates main >> /etc/apt/sources.list \
	&& echo deb-src http://ftp.us.debian.org/debian/ buster-updates main >> /etc/apt/sources.list \
	&& echo deb http://ftp.us.debian.org/debian buster-backports main >> /etc/apt/sources.list \
	&& echo deb-src http://ftp.us.debian.org/debian buster-backports main >> /etc/apt/sources.list \
	&& echo deb https://apt.blobfolio.com/debian/ buster main >> /etc/apt/sources.list \
	&& echo deb https://packages.sury.org/php/ buster main >> /etc/apt/sources.list \
	&& echo deb http://ppa.launchpad.net/apt-fast/stable/ubuntu bionic main >> /etc/apt/sources.list \
	&& echo "deb https://deb.nodesource.com/node_13.x $(lsb_release -s -c) main" >> /etc/apt/sources.list \
	\
	&& apt-get update \
	&& echo debconf apt-fast/dlflag boolean true | debconf-set-selections \
	&& echo debconf apt-fast/aptmanager string apt-get | debconf-set-selections \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y apt-fast \
	&& apt-fast dist-upgrade -y \
	\
	&& apt-fast install -y --no-install-recommends \
		bc \
		brotli \
		bzip2 \
		git \
		gzip \
		jq \
		just \
		less \
		mariadb-server \
		nodejs \
		openssh-client \
		php-pear \
		php-php-gettext \
		php-phpseclib \
		php7.3-bcmath \
		php7.3-bz2 \
		php7.3-cli \
		php7.3-common \
		php7.3-curl \
		php7.3-gd \
		php7.3-gmp \
		php7.3-imap \
		php7.3-intl \
		php7.3-json \
		php7.3-mbstring \
		php7.3-mysql \
		php7.3-opcache \
		php7.3-readline \
		php7.3-xml \
		php7.3-zip \
		rsync \
		ruby \
		sass \
		sassc \
		sudo \
		unzip \
		vim \
		webp \
		whiptail \
		wp-cli \
		xz-utils \
		zip \
	\
	&& wget -q -O /tmp/watchexec.deb https://github.com/watchexec/watchexec/releases/download/1.12.0/watchexec-1.12.0-x86_64-unknown-linux-gnu.deb \
	&& dpkg -i /tmp/watchexec.deb \
	&& rm /tmp/watchexec.deb \
	\
	&& apt-get autoremove --purge -y \
	&& apt-get clean -y \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /tmp/* \
	&& rm -rf /var/log/*

# Install too many NPM things.
RUN set -eux; \
	mkdir /tmp/npm-cache \
	&& npm update -g --cache /tmp/npm-cache npm \
	&& npm install -g --unsafe-perm \
		--cache /tmp/npm-cache \
		csso-cli \
		eslint \
		grunt \
		grunt-cli \
		grunt-contrib-sass \
		grunt-sass \
		node-gyp \
		node-sass \
		onchange \
		svgo \
		terser \
	&& rm -rf /tmp/npm-cache

# Install Composer.
RUN set -eux; \
	wget -q -O /usr/bin/composer https://getcomposer.org/download/1.9.1/composer.phar \
	&& chmod 755 /usr/bin/composer

# Install PHPAB.
RUN set -eux; \
	wget -q -O /usr/bin/phpab https://github.com/theseer/Autoload/releases/download/1.25.8/phpab-1.25.8.phar \
	&& chmod 755 /usr/bin/phpab

# Install PHPUnit.
RUN set -eux; \
	wget -q -O /usr/bin/phpunit https://phar.phpunit.de/phpunit-8.phar \
	&& chmod 755 /usr/bin/phpunit

# Install PHPCS.
RUN set -eux; \
	mkdir /opt/phpcs \
	&& wget -q -O /opt/phpcs/tmp.zip https://apt.blobfolio.com/other/blobfolio-phpcs.zip \
	&& cd /opt/phpcs \
	&& unzip tmp.zip \
	&& rm tmp.zip \
	&& composer install \
	&& ln -s /opt/phpcs/lib/vendor/bin/phpcs /usr/bin/phpcs \
	&& ln -s /opt/phpcs/lib/vendor/bin/phpcbf /usr/bin/phpcbf \
	&& composer clear \
	&& composer clearcache

# Copy setup files.
COPY setup/.vimrc /root/.vimrc
COPY setup/.bashrc /root/.bashrc
COPY setup/.profile /root/.profile
COPY setup/entrypoint.sh /opt/entrypoint.sh

# Note the container version.
RUN set -eux; \
	mkdir /share \
	&& echo "20191229" > /opt/righteous

# This is how it begins.
WORKDIR /share
ENTRYPOINT /opt/entrypoint.sh
CMD /bin/bash
