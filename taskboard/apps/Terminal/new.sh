folder="$1"
jiranum="$2"
repo="$3"

osascript -e "
  tell app \"Terminal\"
    do script \"\
      J='${jiranum}';\
      $(realpath "$(dirname "${BASH_SOURCE[0]}")/../../..")/scripts/ttitle.sh '${jiranum}';\
      cd ${folder};\
      source '$(pwd)/startup-script.sh' '${repo}';\
    \"
  end tell
"
