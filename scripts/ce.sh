if [ ! "$1" ] || [ "$1" = -h ] || [ "$1" = 'ce' ] || [ "$1" = 'ce.sh' ]
then
  ls "$(dirname "${BASH_SOURCE[0]}")" | grep -v '^ce.sh$' | grep -v '^README.md$'
  "$(dirname "${BASH_SOURCE[0]}")/../yext-ce-tools/scripts/ce.sh"
else
  script="$1"
  [[ $script == *\.* ]] || script="${script}.sh"

  if [ -f "$(dirname "${BASH_SOURCE[0]}")/${script}" ]
  then
    shift
    "$(dirname "${BASH_SOURCE[0]}")/${script}" $@
  else
    "$(dirname "${BASH_SOURCE[0]}")/../yext-ce-tools/scripts/ce.sh" $@
  fi
fi
