#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/funcs.sh"
assert_git_repo

if [ "$1" = "-t" ]
then
	shift
	tag="-t ${1}"
	shift
fi

message="$@"

cwd="$(pwd)"
cd src
"$(dirname "${BASH_SOURCE[0]}")/../scripts/avn.sh"
cd "$cwd"

if [ "$message" ]
then
	git finish $tag -m "$message"
else
	git finish $tag
fi
