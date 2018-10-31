# Most of these were taken from pages-flow-common

tag_format_regex="^([0-9]+)\.([0-9]+)\.([0-9]+)$"
jira_regex="[A-Z]+-[0-9]+"

die() { echo "$@" >&2; exit 1; }

# Asserts that current dir is in a git repo
assert_git_repo() {
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    die "Error: Not a git repository"
  fi
}

# Returns the name of the current branch
get_current_branch() {
  set -e

  assert_git_repo
  branch_name="$(git symbolic-ref HEAD 2>/dev/null)" ||
  branch_name="(no branch name)"
  branch_name=${branch_name##refs/heads/}

  echo "$branch_name"
}

# Returns the group of the current branch, defined by being before
# the first forward slash -- dies if no group is found
get_current_group() {
  set -e

  group_regex="([^\/]*)/"
  branch_name="$(get_current_branch)"
  if [[ $branch_name =~ $group_regex ]]; then
    name="${BASH_REMATCH[1]}"
    echo "${name}"
  else
    die "Error: Cannot find current group -- are you in a grouped branch?"
  fi
}