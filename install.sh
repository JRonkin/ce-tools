if [ ! "$(grep "# yext ce tools" < "${HOME}/.bash_profile")" ]
then
	cd "$(dirname "${BASH_SOURCE[0]}")"
	export PATH="$PATH:$(pwd)/shortcuts"
	printf "
# yext ce tools
export PATH=\"\$PATH:$(pwd)/shortcuts\"
" >> "$HOME"/.bash_profile
fi
