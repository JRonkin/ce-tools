# Current directory is the app's folder in ce-tools/taskboard/apps/

folder="$1"
jiranum="$2"
repo="$3"
position="$4"
size="$5"

[ "$position" ] || position='0, 0'
[ "$size" ] || size='1000, 1000'

# This script should create new window(s) of the app for the jira number and/or repo.
# The windows should use the position and size given, if possible.
# Since position or size may be empty, default positions and sizes are set as fallbacks.

# There is no default action for this command. It must be implemented for each app.
