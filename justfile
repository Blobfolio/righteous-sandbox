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

src_dir      := justfile_directory() + "/docker"

docker_image := "righteous/sandbox"
docker_name  := "righteous"
docker_sig   := "/opt/righteous"



# Build Environment.
@build: _no_docker _requirements
	cd "{{ src_dir }}" \
		&& docker build \
			-t "{{ docker_image }}":latest \
			-f Dockerfile .


# Build If Needed.
@build-if: _no_docker _requirements
	[ ! -z "$( docker images | grep "{{ docker_image }}" )" ] || just rebuild


# Launch Environment.
@launch DIR INIT="": build-if
	docker run \
		-e "righteous_init={{ INIT }}" \
		--rm \
		-v "{{ DIR }}":/share \
		-it \
		--name {{ docker_name }} \
		{{ docker_image }}


# Rebuild Environment.
@rebuild: _no_docker _requirements
	# Make sure the image is removed.
	just remove

	# Force an update of Debian.
	docker pull debian:buster-slim

	# Build it.
	just build


# Remove Environment.
@remove: _no_docker _requirements
	[ -z "$( docker images | grep "{{ docker_image }}" )" ] || docker rmi "{{ docker_image }}"



##        ##
# INTERNAL #
##        ##

# General Requirements.
@_requirements:
	# Docker should exist and be running.
	[ $( command -v docker ) ] || just _die "Docker is required."

	# Git is required.
	[ $( command -v git ) ] || just _die "Git is required."


# Tasks Not Allowed Inside Docker.
@_no_docker:
	[ ! -f "{{ docker_sig }}" ] || just _die "This task is meant to be run on a local machine."



##             ##
# NOTIFICATIONS #
##             ##

# Echo an error.
@_error COMMENT:
	>&2 echo "\e[31;1m[Error] \e[0;1m{{ COMMENT }}\e[0m"

# Error and exit.
@_die COMMENT:
	just _error "{{ COMMENT }}"
	exit 1
