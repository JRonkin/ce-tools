#!/usr/bin/env bash
if [[ ! "$(grep "# ce tools" < "${HOME}/.bash_profile")" ]]
then
	cd "$(dirname "${BASH_SOURCE[0]}")"
	export PATH="$PATH:$(pwd)/shortcuts"
	printf "
# ce tools
export PATH=\"\$PATH:$(pwd)/shortcuts\"
" >> "$HOME"/.bash_profile
fi
