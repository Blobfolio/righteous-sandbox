# Righteous Sandbox
#
# This is a crude containerized build environment that moots the need to
# install things like Node, PHPUnit, etc., locally.
#
# It should contain *most* needed tools out of the box, but being based
# on Debian stable, anything else is just an `apt-fast install` away.
#
# BUILD:
# docker build -t righteous/sandbox:latest -f Dockerfile .
#
# RUN:
# docker run --rm -v $PWD:/share -it --name righteous righteous/sandbox

FROM buildpack-deps:buster

# Labels.
LABEL Name="Righteous Sandbox" \
	Version="RSVERSION"

# Binary paths.
ARG composer_url=https://getcomposer.org/download/1.9.1/composer.phar
ARG	ninja_url=https://github.com/ninja-build/ninja/releases/download/v1.9.0/ninja-linux.zip
ARG	phpab_url=https://github.com/theseer/Autoload/releases/download/1.25.8/phpab-1.25.8.phar
ARG	phpcs_url=https://apt.blobfolio.com/other/blobfolio-phpcs.zip
ARG	phpunit_url=https://phar.phpunit.de/phpunit-8.phar
ARG	rust_url=https://sh.rustup.rs
ARG	watchexec_url=https://github.com/watchexec/watchexec/releases/download/1.12.0/watchexec-1.12.0-x86_64-unknown-linux-gnu.deb

# Rust requires a few other bits of knowledge to install itself.
ARG rust_version=1.40.0
ENV	RUSTUP_HOME=/usr/local/rustup \
	CARGO_HOME=/usr/local/cargo \
	PATH=/usr/local/cargo/bin:$PATH

# Note the container version.
RUN set -eux; \
	mkdir /share \
	&& echo "RSVERSION" > /opt/righteous-sandbox.version \
	&& echo "$( date -u +"%F %T" ) UTC" > /opt/righteous-sandbox.built

# Run various APT operations.
RUN set -eux; \
	cd /tmp \
	&& echo "hsts=0" > /root/.wgetrc \
	&& apt-get update \
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
	&& wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
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
	&& echo deb http://apt.llvm.org/buster/ llvm-toolchain-buster-8 main >> /etc/apt/sources.list \
	&& echo deb-src http://apt.llvm.org/buster/ llvm-toolchain-buster-8 main >> /etc/apt/sources.list \
	&& echo "deb https://deb.nodesource.com/node_13.x buster main" >> /etc/apt/sources.list \
	\
	&& apt-get update \
	&& echo debconf apt-fast/dlflag boolean true | debconf-set-selections \
	&& echo debconf apt-fast/aptmanager string apt-get | debconf-set-selections \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y apt-fast \
	&& apt-fast dist-upgrade -y \
	\
	&& apt-fast install -y --no-install-recommends \
		bc \
		bison \
		brotli \
		build-essential \
		bzip2 \
		clang-8 \
		clang-format-8 \
		clang-tools-8 \
		cmake \
		flex \
		g++ \
		gcc \
		git \
		gzip \
		help2man \
		jq \
		jq \
		just \
		kmod \
		less \
		less \
		libc++-8-dev \
		libc++abi-8-dev \
		libclang-8-dev \
		libclang-common-8-dev \
		libclang1-8 \
		libfl-dev \
		libfuzzer-8-dev \
		libllvm-8-ocaml-dev \
		libllvm8 \
		libmpc-dev \
		libmpfr-dev \
		libomp-8-dev \
		libz3-dev \
		lld-8 \
		lldb-8 \
		llvm-8 \
		llvm-8-dev \
		llvm-8-runtime \
		mariadb-server \
		nasm \
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
		python-clang-8 \
		re2c \
		rsync \
		ruby \
		sass \
		sassc \
		sudo \
		unzip \
		vim \
		vim \
		webp \
		whiptail \
		wp-cli \
		xz-utils \
		yasm \
		zip \
	\
	&& wget -q -O /tmp/watchexec.deb $watchexec_url \
	&& dpkg -i /tmp/watchexec.deb \
	&& rm /tmp/watchexec.deb \
	\
	&& apt-get autoremove --purge -y \
	&& apt-get clean -y \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /tmp/* \
	&& rm -rf /var/log/*

# Install Ninja.
RUN set -eux; \
	wget -q -O /tmp/ninja.zip $ninja_url \
	&& cd /tmp \
	&& unzip ninja.zip \
	&& mv ninja /usr/bin/ninja \
	&& rm -rf /tmp/*

# Install Rust.
RUN set -eux; \
	wget -q -O /tmp/rustup.sh $rust_url \
	&& chmod +x /tmp/rustup.sh \
	&& /tmp/rustup.sh -y --profile minimal --default-toolchain $rust_version \
    && rustup --version \
    && cargo --version \
    && rustc --version \
	&& rm -rf /tmp/*

# Install (too many) NPM things.
RUN set -eux; \
	npm set cache /tmp/npm-cache \
	&& npm set package-lock false \
	&& npm set save false \
	&& npm set unsafe-perm true \
	&& npm update -g npm \
	&& npm install -g \
		csso-cli \
		eslint \
		grunt \
		grunt-cli \
		grunt-contrib-sass \
		grunt-sass \
		node-gyp \
		node-sass \
		onchange \
		stylecow \
		svgo \
		terser \
		uglify-es \
	&& rm -rf /tmp/*

# Install Composer.
RUN set -eux; \
	wget -q -O /usr/bin/composer $composer_url \
	&& chmod 755 /usr/bin/composer

# Install PHPAB.
RUN set -eux; \
	wget -q -O /usr/bin/phpab $phpab_url \
	&& chmod 755 /usr/bin/phpab

# Install PHPUnit.
RUN set -eux; \
	wget -q -O /usr/bin/phpunit $phpunit_url \
	&& chmod 755 /usr/bin/phpunit

# Install PHPCS.
RUN set -eux; \
	mkdir /opt/phpcs \
	&& wget -q -O /opt/phpcs/tmp.zip $phpcs_url \
	&& cd /opt/phpcs \
	&& unzip tmp.zip \
	&& rm tmp.zip \
	&& composer install \
	&& ln -s /opt/phpcs/lib/vendor/bin/phpcs /usr/bin/phpcs \
	&& ln -s /opt/phpcs/lib/vendor/bin/phpcbf /usr/bin/phpcbf \
	&& find /opt/phpcs -iname '*.md' -delete \
	&& composer clear \
	&& rm -rf /root/.composer

# Copy setup files.
COPY setup/.vimrc /root/.vimrc
COPY setup/.bashrc /root/.bashrc
COPY setup/.profile /root/.profile
COPY setup/entrypoint.sh /opt/entrypoint.sh

# This is how it begins.
WORKDIR /share
ENTRYPOINT /opt/entrypoint.sh
CMD /bin/bash
