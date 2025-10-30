#!/bin/bash
set -e

# Make sure we're inside a container.
[ -f "/opt/righteous-sandbox.version" ] || exit 1

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

jqval() {
	cat "/share/.righteous-sandbox.json" | \
		jq ".$1" | \
		grep -v null | \
		xargs echo -n
}

boolval() {
	local VAL="$( jqval $1 )"
	if [ "$VAL" == "true" ] || [ "$VAL" == "true" ]; then
		echo "true"
	else
		echo ""
	fi
}

# Parse project settings, if they exist.
if [ -f "/share/.righteous-sandbox.json" ]; then
	cd /share

	# Apt updates.
	APT="$( boolval "apt_update" )"
	if [ "$APT" == "true" ]; then
		DEBIAN_FRONTEND=noninteractive apt-get update -qq
		DEBIAN_FRONTEND=noninteractive apt-fast dist-upgrade -y
	fi

	# Node updates.
	NPM="$( boolval "npm_install" )"
	if [ "$NPM" == "true" ]; then
		if [ -f "/share/package.json" ]; then
			npm i --quiet
			chown -R --reference "/share/package.json" "/share/node_modules"
		fi
	fi

	# Get rid of any Cargo.lock files.
	find . -name 'Cargo.lock' -type f -delete

	# Run Just init task?
	INIT="$( jqval "just_init" )"
	if [ -n "$INIT" ]; then
		if [ -f "/share/justfile" ]; then
			just "$INIT"
		fi
	fi

	# Update Rust?
	RUST="$( boolval "rust_update" )"
	if [ "$RUST" == "true" ]; then
		# Do we need to install rust?
		if [ -z "$( which rustup )" ]; then
			echo "Installing Rust"

			wget -q -O /tmp/rustup.sh https://sh.rustup.rs
			chmod +x /tmp/rustup.sh
			/tmp/rustup.sh -y --profile minimal --default-toolchain stable

			rustup component add clippy
			rustup component add llvm-tools-preview
			rustup component add rustfmt
			rm -rf /usr/local/cargo/registry/*

			DEBIAN_FRONTEND=noninteractive apt-get update -qq

			rm /tmp/rustup.sh
		else
			env RUSTUP_PERMIT_COPY_RENAME=true rustup --quiet update 2>/dev/null || true
		fi

		if [ -f "/share/Cargo.toml" ]; then
			echo ""
			cargo outdated --depth 1 || true
			echo ""
		fi
	fi

	# List Just tasks?
	LIST="$( boolval "just_list" )"
	if [ "$LIST" == "true" ]; then
		just --list
	fi
fi

# Drop to bash.
exec "/bin/bash"
