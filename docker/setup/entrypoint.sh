#!/bin/bash
set -e

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
echo -e "    \\/  .__    ;    \\   \`-.  \e[96;1mRighteous Sandbox\e[0m"
echo -e "     ;     \"-,/_..--\"\`-..__) \e[95;1mv$( cat /opt/righteous )\e[0m"
echo "     '\"\"--.._:"
echo ""
echo ""

# Run the init task, if any.
if [ ! -z "${righteous_init}" ]; then
	cd /share && just "${righteous_init}"
fi

# Drop to bash.
exec "/bin/bash"
