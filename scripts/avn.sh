#!/usr/bin/env bash
# avn only triggers after doing 'cd' to a directory with .node-version
# That doesn't work in scripts, and I don't know how to trigger it manually.
# This script solves that problem.

if [ -f .node-version ]
then
	nodeVersion="$(cat .node-version)"
	if [[ "$nodeVersion" =~ [0-9]+(\.[0-9x])* ]]
	then
		installedMatch="$(n ls | grep " $(echo "${nodeVersion%x*}" | cut -d x -f 1)" | tail -n 1 | tr -d ' ο')" | sed 's/\[[^m]*m//g'
		if [ "$installedMatch" ]
		then
			n "$installedMatch"
		else
			n "${nodeVersion%.x*}"
		fi
	fi
fi
