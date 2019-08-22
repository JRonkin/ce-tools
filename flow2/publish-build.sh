source "$(dirname "${BASH_SOURCE[0]}")/funcs.sh"
assert_git_repo

group="$(get_current_group 2>/dev/null)"

if [ "$group" ]
then
  pgs publish --branch "${group}/build" --noopen $@
else
  pgs publish --noopen $@
fi