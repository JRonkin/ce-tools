folder="$1"
jiranum="$2"
repo="$3"
position="$4"
size="$5"

if [ "$position" ] && [ "$size" ]
then
  bounds="${position}, $(( ${position%,*} + ${size%,*} )), $(( ${position#*,} + ${size#*,} ))"

  osascript -e "
    tell app \"Terminal\"
      set windowBounds to {${bounds}}
      set windowHeight to (item 4 of windowBounds - item 2 of windowBounds)
      set the bounds of the front window whose name contains \"${jiranum} — 1 — \" to windowBounds
      set item 2 of windowBounds to (item 2 of windowBounds + windowHeight)
      set item 4 of windowBounds to (item 4 of windowBounds + windowHeight)
      set the bounds of the front window whose name contains \"${jiranum} — 2 — \" to windowBounds
    end tell
  "
fi
