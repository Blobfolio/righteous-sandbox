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
repo         := "https://github.com/Blobfolio/righteous-sandbox.git"
version      := "1.0.0"

docker_image := "righteous/sandbox"
docker_name  := "righteous"
docker_sig   := "/opt/righteous-sandbox.version"



# Build Environment.
@build: _requirements
	# We want to make a copy of the Dockerfile to set the version, etc.
	cp "{{ src_dir }}/Dockerfile" "{{ src_dir }}/Dockerfile.righteous"
	sed -i "s/VERSION/{{ version }}/g" "{{ src_dir }}/Dockerfile.righteous"

	# Build!
	cd "{{ src_dir }}" \
		&& docker build \
			-t "{{ docker_image }}":latest \
			-f Dockerfile.righteous .

	# Clean up.
	rm "{{ src_dir }}/Dockerfile.righteous"


# Build If Needed.
@build-if: _requirements
	[ ! -z "$( docker images | grep "{{ docker_image }}" )" ] || just rebuild


# Launch Environment.
@launch DIR: build-if
	docker run \
		--rm \
		-v "{{ DIR }}":/share \
		-it \
		--name {{ docker_name }} \
		{{ docker_image }}


# Rebuild Environment.
@rebuild: _requirements
	# Make sure the image is removed.
	just remove

	# Force an update of Debian.
	docker pull debian:buster-slim

	# Build it.
	just build


# Remove Environment.
@remove: _requirements
	[ -z "$( docker images | grep "{{ docker_image }}" )" ] || docker rmi "{{ docker_image }}"


# Pull sources from master and then rebuild.
@update: _requirements
	# Update self.
	git pull

	# Update container.
	just rebuild


# Initialization task example.
@_init_example: _only_docker
	# Print something so we know it worked.
	echo "This is an example initialization task."



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

# Echo an error.
@_error COMMENT:
	>&2 echo "\e[31;1m[Error] \e[0;1m{{ COMMENT }}\e[0m"

# Error and exit.
@_die COMMENT:
	just _error "{{ COMMENT }}"
	exit 1
