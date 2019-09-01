folder="$1"
jiranum="$2"
repo="$3"
position="$4"
size="$5"

[ "$position" ] || position='0, 347'
[ "$size" ] || size='571, 353'

osascript -e "
  tell app \"Terminal\"
    do script \"J=${jiranum}; cd ${folder}; source '$(pwd)/startup-script.sh' '${repo}'\"
    set the custom title of the front window to \"${jiranum}\"
    set the position of the front window whose name contains \"${jiranum} — \" to {${position}}
    set the size of the front window whose name contains \"${jiranum} — \" to {${size}}
  end tell
" &
