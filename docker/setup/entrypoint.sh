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
echo "     '\"\"--.._:"
echo ""
echo ""

# Parse project settings, if they exist.
if [ -f "/share/.righteous-sandbox.json" ]; then
	_npm_install="$( cat "/share/.righteous-sandbox.json" | jq -r '.npm_install' | grep -v "none" )"
	_just_init="$( cat "/share/.righteous-sandbox.json" | jq -r '.just_init' | grep -v "none" )"
	_just_list="$( cat "/share/.righteous-sandbox.json" | jq -r '.just_list' | grep -v "none" )"

	# Install NPM dependencies?
	if [ "true" == "${_npm_install,,}" ] && [ -f "/share/package.json" ]; then
		cd /share && npm i
		chown -R --reference /share/package.json /share/node_modules
	fi

	# Only look at Just-related tasks if there's a justfile present.
	if [ -f "/share/justfile" ]; then
		# Initialization with a Just task?
		if [ ! -z "${_just_init}" ]; then
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
