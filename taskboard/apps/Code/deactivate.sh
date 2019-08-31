folder="$1"
jiranum="$2"
repo="$3"

osascript -e "tell app \"System Events\" to tell process \"Code\" to tell every window whose name contains \"${jiranum}\" to click button 3"
