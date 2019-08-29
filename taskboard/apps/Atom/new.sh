folder="$1"
jiranum="$2"
repo="$3"
position="$4"
size="$5"

[ "$position" ] || position='279, 23'
[ "$size" ] || size='1331, 1027'

if [ "$repo" ]
then
  selector="window whose name contains \"/${jiranum}/${repo}\""

  atom "${folder}/${repo}" && sleep 2 &&
    osascript -e "
      tell app \"Atom\"
        set timer to 0
        repeat until the length of (get every ${selector}) > 0 or timer > 15
          delay 0.5
          set timer to timer + 0.5
        end repeat
        set the position of every ${selector} to {${position}}
        set the size of every ${selector} to {${size}}
      end tell
    " &
fi
