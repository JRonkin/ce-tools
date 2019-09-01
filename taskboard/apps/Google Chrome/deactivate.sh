folder="$1"
jiranum="$2"
repo="$3"

osascript -e "tell app \"Google Chrome\" to set minimized of every window where the url of the 1st tab contains \".atlassian.net/browse/${jiranum}\" to true"
