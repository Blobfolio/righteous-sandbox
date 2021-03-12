#!/bin/bash
set -e

# Make sure we're inside a container.
[ -f "/opt/righteous-sandbox.version" ] || exit 1

# Make sure Rust stable is populated.
[ -d "/usr/local/rustup/toolchains/stable-x86_64-unknown-linux-gnu" ] || mv "/usr/local/rustup/.stable" "/usr/local/rustup/toolchains/stable-x86_64-unknown-linux-gnu"

# Print a fun ASCII greeting.
echo "                              __"
echo "                     /\\    .-\" /"
echo "                    /  ; .'  .'"
echo "                   :   :/  .'"
echo "                    \\  ;-.'   Bunny seeing you here!"
echo "       .--\"\"\"\"--..__/     \`."
echo "     .'           .'    \`o  \\"
echo "    /                    \`   ;"
echo "   :                  \\      :"
echo " .-;        -.         \`.__.-'"
echo ":  ;          \\     ,   ;"
echo "'._:           ;   :   ("
echo -e "    \\/  .__    ;    \\   \`-.  \e[96;1mRighteous Sandbox\e[0m \e[95;1mv$( cat /opt/righteous-sandbox.version )\e[0m"
echo -e "     ;     \"-,/_..--\"\`-..__) \e[2mBuilt: $( cat /opt/righteous-sandbox.built )\e[0m"
echo -e "     '\"\"--.._:               \e[2m$( cat /etc/os-release | grep PRETTY_NAME | cut -d '=' -f2 | cut -d '"' -f2 )\e[\0m"
echo ""
echo ""

# Parse project settings, if they exist.
if [ -f "/share/.righteous-sandbox.json" ]; then
	_apt_update="$( cat "/share/.righteous-sandbox.json" | jq -r '.apt_update' | grep -v 'none' )"
	_npm_install="$( cat "/share/.righteous-sandbox.json" | jq -r '.npm_install' | grep -v 'none' )"
	_rust_update="$( cat "/share/.righteous-sandbox.json" | jq -r '.rust_update' | grep -v 'none' )"
	_just_init="$( cat "/share/.righteous-sandbox.json" | jq -r '.just_init' | grep -v 'none' )"
	_just_list="$( cat "/share/.righteous-sandbox.json" | jq -r '.just_list' | grep -v 'none' )"

	# Run updates?
	if [ "true" == "${_apt_update,,}" ]; then
		apt-get update -qq
		DEBIAN_FRONTEND=noninteractive apt-fast dist-upgrade -y
	fi

	# Install NPM dependencies?
	if [ "true" == "${_npm_install,,}" ] && [ -f "/share/package.json" ]; then
		cd /share && npm i
		chown -R --reference /share/package.json /share/node_modules
	fi

	# Update Rust.
	if [ "true" == "${_rust_update,,}" ]; then
		env RUSTUP_PERMIT_COPY_RENAME=true rustup --quiet update

		if [ -f "/share/Cargo.toml" ]; then
			[ ! -f "/share/Cargo.lock" ] || rm "/share/Cargo.lock"
			cd /share && cargo update && cargo outdated
		fi
	fi

	# Only look at Just-related tasks if there's a justfile present.
	if [ -f "/share/justfile" ]; then
		# Initialization with a Just task?
		if [ ! -z "${_just_init}" ] && [ "null" != "${_just_init,,}" ]; then
			cd /share && just "${_just_init}"
		fi

		# List Just tasks?
		if [ "true" == "${_just_list,,}" ]; then
			cd /share && just --list
		fi
	fi
fi

# Drop to bash.
exec "/bin/bash"
