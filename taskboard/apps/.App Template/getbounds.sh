# Current directory is the app's folder in ce-tools/taskboard/apps/

folder="$1"
jiranum="$2"
repo="$3"

# This script should print the position and size of the app's front window for a jira number and/or repo.
# Format: 'LEFT, TOP|WIDTH, HEIGHT'
# A window 100 pixels from the left of the screen, 200 pixels from the top of the screen,
# 300 pixels wide, and 400 pixels high should print this:
# 100, 200|300, 400

# The following is a default script and may need to be customized for the app:

app="$(basename "$(pwd)")"
selector="window whose name contains \"${jiranum}\""

osascript -e "
  tell app \"System Events\"
    tell process \"${app}\"
      set pos to the position of the front ${selector}
      set siz to the size of the front ${selector}
    end tell
  end tell

  set AppleScript's text item delimiters to {\", \"}
  (pos as text) & \"|\" & (siz as text)
"
