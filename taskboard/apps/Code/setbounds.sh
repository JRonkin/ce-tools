folder="$1"
jiranum="$2"
repo="$3"
position="$4"
size="$5"

# This script should set the given position and size of the app's window(s).
# If position and size are empty, default values may be used or this script may do nothing.

# The following is a default script and may need to be customized for the app:

selector="window whose name contains \"${jiranum}\""

if [ "$position" ] && [ "$size" ]
then
  bounds="${position}, $(( ${position%,*} + ${size%,*} )), $(( ${position#*,} + ${size#*,} ))"

  osascript -e "
    tell app \"System Events\"
      tell process \"Code\"
        set timer to 0
        repeat until the length of (get every ${selector}) > 0 or timer > 15
          delay 0.5
          set timer to timer + 0.5
        end repeat
        set the position of every ${selector} to {${position}}
        set the size of every ${selector} to {${size}}
      end tell
    end tell
  " &
fi
