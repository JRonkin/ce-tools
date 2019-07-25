#!/usr/bin/env bash
if [[ "$1" = 'dist' ]]
then
	dist='serve:dist'
fi

"$(dirname "${BASH_SOURCE[0]}")"/avn.sh
YEXT_NEW_PAGER='' grunt $dist
