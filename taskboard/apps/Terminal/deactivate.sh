folder="$1"
jiranum="$2"
repo="$3"

osascript -e "tell app \"Terminal\" to set miniaturized of every window whose name contains \"${jiranum} — \" to true"
