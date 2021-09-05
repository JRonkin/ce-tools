folder="$1"
jiranum="$2"
repo="$3"

osascript -e "
  tell app \"Terminal\"
    set pos to the position of the front window whose name contains \"${jiranum} — \"
    set siz to the size of the front window whose name contains \"${jiranum} — \"
  end tell

  set AppleScript's text item delimiters to {\", \"}
  (pos as text) & \"|\" & (siz as text)
"
