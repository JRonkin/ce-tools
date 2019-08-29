folder="$1"
jiranum="$2"
repo="$3"
monitors="$4"
bounds="$5"

if [ ! "$bounds" ]
then
  bounds='0, 347, 571, 700'
  [ $monitors -gt 1 ] && bounds='3255, 390, 3840, 756'
fi

osascript -e "
  tell app \"Terminal\"
    do script \"J=${jiranum}; cd ${folder}; source '$(realpath "$(dirname "${BASH_SOURCE[0]}")")/startup-script.sh' '${repo}'\"
    set the custom title of the front window to \"${jiranum}\"
    set the bounds of the front window whose name contains \"${jiranum} — \" to {${bounds}}
  end tell
" &
