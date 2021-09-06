folder="$1"
jiranum="$2"
repo="$3"
position="$4"
size="$5"

if [ "$repo" ] && [ "$position" ] && [ "$size" ]
then
  bounds="${position}, $(( ${position%,*} + ${size%,*} )), $(( ${position#*,} + ${size#*,} ))"
  selector="window whose name contains \"/${jiranum}/${repo}\""

  osascript -e "
    tell app \"Atom\"
      set timer to 0
      repeat until the length of (get every ${selector}) > 0 or timer > 15
        delay 0.5
        set timer to timer + 0.5
      end repeat
      set the bounds of every ${selector} to {${bounds}}
    end tell
  "
fi
