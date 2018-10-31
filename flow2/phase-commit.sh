source "$(dirname "${BASH_SOURCE[0]}")/funcs.sh"
assert_git_repo

if [ "$1" = "-a" ]
then
	git add -A
	shift
fi

group="$(get_current_group)"
message="$@"

if [ "$message" ] && [[ "$group" =~ $jira_regex ]]
then
	message="${group} ${message}"
fi

git commit -m "$message"