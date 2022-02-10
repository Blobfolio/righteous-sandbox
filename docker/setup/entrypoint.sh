#!/bin/bash
set -e

# Make sure we're inside a container.
[ -f "/opt/righteous-sandbox.version" ] || exit 1

# Make sure Rust stable is populated.
[ -d "/usr/local/rustup/toolchains/stable-x86_64-unknown-linux-gnu" ] || tar -xf "/usr/local/rustup/stable.tar.xz" -C "/usr/local/rustup/toolchains"

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
php /opt/entrypoint.php

# Drop to bash.
exec "/bin/bash"
