folder="$1"
jiranum="$2"
repo="$3"

osascript -e "tell app \"Terminal\" to close every window whose name contains \"${jiranum} — \""
