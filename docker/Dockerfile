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
COPY setup/keyrings/ /usr/share/keyrings/
COPY setup/righteous.sources /etc/apt/sources.list.d/righteous.sources.bak

# Set it up!
RUN set -eux; \
	cd /tmp \
	&& echo "hsts=0" > /root/.wgetrc \
	&& chown -R root: /usr/share/keyrings \
	&& apt-get update -qq \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		ca-certificates \
		dirmngr \
		gnupg \
	&& echo '' > /etc/apt/sources.list \
	&& mv /etc/apt/sources.list.d/righteous.sources.bak /etc/apt/sources.list.d/righteous.sources \
	&& apt-get update \
	\
	&& echo debconf apt-fast/maxdownloads string 4 | debconf-set-selections \
	&& echo debconf apt-fast/dlflag boolean true | debconf-set-selections \
	&& echo debconf apt-fast/aptmanager string apt-get | debconf-set-selections \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt-fast \
	\
	&& DEBIAN_FRONTEND=noninteractive apt-fast install -y --no-install-recommends \
		aria2 \
		bash-completion \
		curl \
		just \
		locales \
		lsb-release \
		wget \
	&& sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
	&& locale-gen \
	\
	&& just --justfile /root/justfile install \
	&& rm /root/justfile

# Copy setup files.
COPY setup/.vimrc setup/.bashrc setup/.profile /root/
COPY setup/entrypoint.sh /opt/entrypoint.sh

# Define some volumes.
VOLUME /usr/local/cargo/registry
VOLUME /usr/local/rustup/toolchains

# This is how it begins.
WORKDIR /share
ENTRYPOINT /opt/entrypoint.sh
CMD /bin/bash
