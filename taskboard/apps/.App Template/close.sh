# Current directory is the app's folder in ce-tools/taskboard/apps/

folder="$1"
jiranum="$2"
repo="$3"

# This script should close the app's window(s) for the jira number and/or repo.

# The following is a default script and may need to be customized for the app:

app="$(basename "$(pwd)")"
selector="window whose name contains \"${jiranum}\""

osascript -e "tell app \"System Events\" to tell process \"${app}\" to tell every ${selector} to click button 1" &>/dev/null
