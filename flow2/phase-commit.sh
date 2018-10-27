source "$(dirname "${BASH_SOURCE[0]}")/funcs.sh"
assert_git_repo

group="$(get_current_group)"
message="$@"

if [ "$message" ] && [[ "$group" =~ "$jira_regex" ]]
then
	message="${1} ${message}"
fi

git commit -m "$message"