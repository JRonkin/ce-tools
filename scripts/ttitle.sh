if [ "$1" ]
then
  osascript -e 'tell app "Terminal" to set the custom title of the front window to "'"$1"'"' &>/dev/null
  echo "$1"
fi
