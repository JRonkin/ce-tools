folder="$1"
jiranum="$2"
repo="$3"
monitors="$4"

bounds='0, 347, 571, 700'
[ $monitors -gt 1 ] && bounds='3255, 390, 3840, 756'
[ "$bounds_Terminal" ] && bounds="$bounds_Terminal"

printf "
  tell app \"Terminal\"
    do script \"J=${jiranum}; cd ${folder}; cd ${repo}; source $(dirname "${BASH_SOURCE[0]}")/script.sh\"
    set the custom title of the front window to \"${jiranum}\"
    set the bounds of the front window whose name contains \"${jiranum} — \" to {${bounds}}
  end tell
" | osascript &
