# This script runs when Terminal opens a new window.
# Current folder is [ITEMS_DIR]/[JIRANUM]
# First agrument is the the current repo, or empty string if none

if [ "$1" ]
then
  cd "$1"

  # Create a new window below the current window to run startup-script-repo.sh
  osascript -e "
    tell app \"Terminal\"
      do script \"\
J='${J}'
$(realpath "$(dirname "${BASH_SOURCE[0]}")/../../..")/scripts/ttitle.sh '${J}'
osascript -e '
  tell app \\\"Terminal\\\"
    set windowBounds to the bounds of window 2 whose name contains \\\"${J} — \\\"
    set windowHeight to (item 4 of windowBounds - item 2 of windowBounds)
    set item 2 of windowBounds to (item 2 of windowBounds + windowHeight)
    set item 4 of windowBounds to (item 4 of windowBounds + windowHeight)
    set the bounds of the front window whose name contains \\\"${J} — \\\" to windowBounds
  end tell
'
cd '$(pwd)'
clear
source '$(realpath "$(dirname "${BASH_SOURCE[0]}")")/startup-script-repo.sh'\"
    end tell
  "

  git branch -v
fi
