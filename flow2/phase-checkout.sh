source "$(dirname "${BASH_SOURCE[0]}")/funcs.sh"
assert_git_repo

group="$(get_current_group)"

git checkout "${group}/${1-trunk}"