folder="$1"
jiranum="$2"
repo="$3"
position="$4"
size="$5"

[ "$position" ] || position='0, 373'
[ "$size" ] || size='571, 339'

bounds="${position}, $(( ${position%,*} + ${size%,*} )), $(( ${position#*,} + ${size#*,} ))"

osascript -e "
  tell app \"Terminal\"
    do script \"J=${jiranum}; cd ${folder}; source '$(pwd)/startup-script.sh' '${repo}'\"
    set new_window to the front window
    set the custom title of new_window to \"${jiranum}\"
    set the bounds of new_window to {${bounds}}
  end tell
" &
