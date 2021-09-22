# This script runs when Terminal opens a new window.
# Current folder is [ITEMS_DIR]/[JIRANUM]

folder="$1"
jiranum="$2"
repo="$3"
position="$4"
size="$5"

if [ "$repo" ]
then
  cd "$repo"

  # Create a new window below the current window to run startup-script-repo.sh
  osascript -e "
    tell app \"Terminal\"
      do script \"\
J='${jiranum}'
$(realpath "$(dirname "${BASH_SOURCE[0]}")/../../..")/scripts/ttitle.sh '${jiranum} — 2'
$(realpath "$(dirname "${BASH_SOURCE[0]}")")/setbounds.sh '${folder}' '${jiranum}' '${repo}' '${position}' '${size}'
cd '$(pwd)'
clear
source '$(realpath "$(dirname "${BASH_SOURCE[0]}")")/startup-script-repo.sh'\"
    end tell
  "

  git branch -v
fi
