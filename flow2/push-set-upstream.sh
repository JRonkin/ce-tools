#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/funcs.sh"
assert_git_repo

git push --set-upstream origin "$(get_current_branch)" $@