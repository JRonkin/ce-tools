# Current directory is the app's folder in ce-tools/taskboard/apps/

folder="$1"
jiranum="$2"
repo="$3"
position="$4"
size="$5"

# This script should create new window(s) of the app for the jira number and/or repo.
# The window(s) should be set to the given position and size if the values are not empty.

# There is no default action for this command. It must be implemented for each app.

# setbounds can be called after creating the window(s) to set the bounds.
./setbounds.sh "$folder" "$jiranum" "$repo" "$position" "$size"
