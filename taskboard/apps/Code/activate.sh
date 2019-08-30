folder="$1"
jiranum="$2"
repo="$3"

if [ "$(osascript -e "tell app \"System Events\" to tell process \"Code\" to get every window whose name contains \"${jiranum}\"" 2>/dev/null)" ]
then
  code "$folder"
fi
