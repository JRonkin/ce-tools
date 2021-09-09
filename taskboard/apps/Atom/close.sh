folder="$1"
jiranum="$2"
repo="$3"

osascript -e "tell app \"Atom\" to close every window whose name contains \"/${jiranum}\"" &>/dev/null
