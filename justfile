##
# Build Tasks
#
# This requires "just" >= 0.5.4.
# See https://github.com/casey/just for more details.
#
# USAGE:
#   just --list
#   just <task>
##

docker_sig   := "/opt/righteous-sandbox.version"
src_dir      := justfile_directory() + "/docker"
repo         := "https://github.com/Blobfolio/righteous-sandbox.git"
version      := "1.1.7"



##      ##
# Usage! #
##      ##

# Launch Sandbox.
launch DIR="": _build-if
	#!/usr/bin/env bash

	_dir=""
	if [ -z "{{ DIR }}" ]; then
		_dir="{{ invocation_directory() }}"
	else
		_dir="$( realpath "{{ DIR }}" )"
		if [ ! -d "${_dir}" ]; then
			just _error "Invalid share directory."
			exit 1
		fi
	fi

	docker run \
		--rm \
		-v "${_dir}":/share \
		-it \
		--name "$( just _dist-image-name )" \
		"$( just _dist-image )"


# Initialization task example.
@_launch-init: _only_docker
	# Print something so we know it worked.
	fyi warning "This is being executed from Righteous Sandbox's source directory."



##                    ##
# Distribution Helpers #
##                    ##

# Output the distribution.
@_dist:
	echo "debian"


# Output the distribution's base image.
@_dist-base-image:
	echo "debian:buster"


# Output the distribution image:tag.
@_dist-image:
	echo "righteous/sandbox:$( just _dist )"


# Output the distribution image's runtime name.
@_dist-image-name:
	echo "righteous_$( just _dist )"




##                ##
# Image Management #
##                ##

# Build Sandbox.
@build: _requirements
	# We want to make a copy of the Dockerfile to set the version, etc.
	cp "{{ src_dir }}/$( just _dist )" "{{ src_dir }}/Dockerfile.righteous"
	sed -i "s/RSVERSION/{{ version }}/g" "{{ src_dir }}/Dockerfile.righteous"

	# Build!
	cd "{{ src_dir }}" \
		&& docker build \
			-t "$( just _dist-image )" \
			-f Dockerfile.righteous .

	# Clean up.
	rm "{{ src_dir }}/Dockerfile.righteous"


# Build Sandbox, but only if missing.
@_build-if: _requirements
	[ ! -z "$( docker images | \
		grep "righteous/sandbox" | \
		grep "$( just _dist )" )" ] || just rebuild


# Rebuild Environment.
@rebuild: _requirements
	just _header "Rebuilding $( just _dist-image )."

	# Make sure the image is removed.
	just remove

	# Force an update of Debian.
	docker pull "$( just _dist-base-image )"

	# Build it.
	just build


# Remove Environment.
@remove: _requirements
	[ -z "$( docker images | \
		grep "righteous/sandbox" | \
		grep "$( just _dist )" )" ] || docker rmi "$( just _dist-image )"


# Pull sources from master and then rebuild.
@update: _requirements
	# Update self.
	git pull

	# Update container.
	just rebuild



##        ##
# INTERNAL #
##        ##

# General Requirements.
@_requirements:
	# Docker should exist and be running.
	[ $( command -v docker ) ] || just _die "Docker is required."

	# Git is required.
	[ $( command -v git ) ] || just _die "Git is required."

	# And these should not be run from within the container.
	just _no_docker


# Tasks Not Allowed Inside Docker.
@_no_docker:
	[ ! -f "{{ docker_sig }}" ] || just _die "This task is meant to be run on a local machine."


# Only Allowed Inside Docker.
@_only_docker:
	[ -f "{{ docker_sig }}" ] || just _die "This task is meant to be run *inside* a container."


# Fix file/directory ownership.
@_fix_chown PATH:
	[ ! -e "{{ PATH }}" ] || chown -R --reference="{{ justfile() }}" "{{ PATH }}"



##             ##
# NOTIFICATIONS #
##             ##

# Task header.
@_header TASK:
	echo "\e[34;1m[Task] \e[0;1m{{ TASK }}\e[0m"

# Echo an error.
@_error COMMENT:
	>&2 echo "\e[31;1m[Error] \e[0;1m{{ COMMENT }}\e[0m"

# Error and exit.
@_die COMMENT:
	just _error "{{ COMMENT }}"
	exit 1
