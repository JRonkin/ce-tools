folder="$1"
jiranum="$2"
repo="$3"

osascript -e "tell app \"Atom\" to set index of every window whose name contains \"/${jiranum}/${repo}\" to 1"
