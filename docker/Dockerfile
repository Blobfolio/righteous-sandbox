# Righteous Sandbox: Debian Bullseye
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



FROM debian:bullseye

# Labels.
LABEL Name="Righteous Sandbox"

# Rust requires a few other bits of knowledge to install itself.
ENV	RUSTUP_HOME=/usr/local/rustup \
	CARGO_HOME=/usr/local/cargo \
	PATH=/usr/local/cargo/bin:$PATH

COPY setup/justfile /root/

# Set it up!
RUN set -eux; \
	cd /tmp \
	&& echo "hsts=0" > /root/.wgetrc \
	&& apt-get update -qq \
	\
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		aria2 \
		bash-completion \
		ca-certificates \
		curl \
		dirmngr \
		gnupg \
		locales \
		lsb-release \
		software-properties-common \
		wget \
	&& sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
	&& locale-gen \
	\
	&& wget -q -O - https://packages.sury.org/php/apt.gpg | apt-key add - \
	&& wget -q -O - https://apt.blobfolio.com/assets/public.asc | apt-key add - \
	&& wget -q -O - https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
	&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A2166B8DE8BDC3367D1901C11EE2FF37CA8DA16B \
	\
	&& echo "deb https://deb.debian.org/debian bullseye main" > /etc/apt/sources.list \
	&& echo "deb-src https://deb.debian.org/debian bullseye main" >> /etc/apt/sources.list \
	&& echo "deb https://deb.debian.org/debian-security/ bullseye-security main" >> /etc/apt/sources.list \
	&& echo "deb-src https://deb.debian.org/debian-security/ bullseye-security main" >> /etc/apt/sources.list \
	&& echo "deb https://deb.debian.org/debian bullseye-updates main" >> /etc/apt/sources.list \
	&& echo "deb-src https://deb.debian.org/debian bullseye-updates main" >> /etc/apt/sources.list \
	&& echo "deb https://deb.debian.org/debian bullseye-backports main" >> /etc/apt/sources.list \
	&& echo "deb-src https://deb.debian.org/debian bullseye-backports main" >> /etc/apt/sources.list \
	\
	&& echo "deb https://apt.blobfolio.com/ bullseye main" > /etc/apt/sources.list.d/blobfolio.list \
	&& echo "deb https://packages.sury.org/php/ bullseye main" > /etc/apt/sources.list.d/php.list \
	&& echo "deb http://ppa.launchpad.net/apt-fast/stable/ubuntu bionic main" > /etc/apt/sources.list.d/apt-fast.list \
	&& echo "deb https://deb.nodesource.com/node_14.x bullseye main" > /etc/apt/sources.list.d/node.list \
	\
	&& apt-get update -qq \
	&& echo debconf apt-fast/maxdownloads string 4 | debconf-set-selections \
	&& echo debconf apt-fast/dlflag boolean true | debconf-set-selections \
	&& echo debconf apt-fast/aptmanager string apt-get | debconf-set-selections \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y apt-fast \
	\
	&& DEBIAN_FRONTEND=noninteractive apt-fast install -y --no-install-recommends just \
	&& just --justfile /root/justfile install \
	&& rm /root/justfile

# Copy setup files.
COPY setup/.vimrc setup/.bashrc setup/.profile /root/
COPY setup/entrypoint.sh /opt/entrypoint.sh
COPY setup/entrypoint.php /opt/entrypoint.php

# Define some volumes.
VOLUME /usr/local/cargo/registry
VOLUME /usr/local/rustup/toolchains

# This is how it begins.
WORKDIR /share
ENTRYPOINT /opt/entrypoint.sh
CMD /bin/bash
