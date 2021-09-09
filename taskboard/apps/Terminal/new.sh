folder="$1"
jiranum="$2"
repo="$3"
position="$4"
size="$5"

osascript -e "
  tell app \"Terminal\"
    do script \"\
J='${jiranum}'
$(realpath "$(dirname "${BASH_SOURCE[0]}")/../../..")/scripts/ttitle.sh '${jiranum}'
$(realpath "$(dirname "${BASH_SOURCE[0]}")")/setbounds.sh '${folder}' '${jiranum}' '${repo}' '${position}' '${size}'
cd ${folder}
clear
source '$(pwd)/startup-script.sh' '${repo}'\"
  end tell
" &>/dev/null
