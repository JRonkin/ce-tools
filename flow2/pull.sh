source "$(dirname "${BASH_SOURCE[0]}")/funcs.sh"
assert_git_repo

branch="$1"
if [ ! "$branch" ]
then
  branch="$(get_current_branch)"
fi

# TODO: find the correct way of pulling a branch without switching to it
# git pull origin "${branch}:${branch}"
git pull
