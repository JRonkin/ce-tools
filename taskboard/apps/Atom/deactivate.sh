folder="$1"
jiranum="$2"
repo="$3"

osascript -e "tell app \"Atom\" to set miniaturized of every window whose name contains \"/${jiranum}\" to true" &>/dev/null
