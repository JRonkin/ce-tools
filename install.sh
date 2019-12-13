pushd "$(dirname "${BASH_SOURCE[0]}")"

git submodule update --init --recursive

if [ ! "$(grep "# ce tools" < "${HOME}/.bash_profile")" ]
then
  export PATH="$PATH:$(pwd)/shortcuts"
  printf "
# ce tools
export PATH=\"\$PATH:$(pwd)/shortcuts:$(pwd)/yext-ce-tools/shortcuts\"
" >> "${HOME}/.bash_profile"
fi

popd
