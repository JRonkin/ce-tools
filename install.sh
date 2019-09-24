if [ ! "$(grep "# ce tools" < "${HOME}/.bash_profile")" ]
then
  export PATH="$PATH:$(realpath "$(dirname "${BASH_SOURCE[0]}")")/shortcuts"
  printf "
# ce tools
export PATH=\"\$PATH:$(realpath "$(dirname "${BASH_SOURCE[0]}")")/shortcuts\"
" >> "${HOME}/.bash_profile"
fi
