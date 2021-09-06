folder="$1"
jiranum="$2"
repo="$3"
position="$4"
size="$5"

if [ "$position" ] && [ "$size" ]
then
  bounds="${position}, $(( ${position%,*} + ${size%,*} )), $(( ${position#*,} + ${size#*,} ))"

  osascript -e "tell app \"Terminal\" to set the bounds of the front window whose name contains \"${jiranum} — \" to {${bounds}}"
fi
