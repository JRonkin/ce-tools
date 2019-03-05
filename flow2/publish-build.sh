source "$(dirname "${BASH_SOURCE[0]}")/funcs.sh"
assert_git_repo

pgs publish --branch "$(get_current_group)/build" --noopen $@