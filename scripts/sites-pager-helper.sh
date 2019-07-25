#!/usr/bin/env bash
domain="$1"

if [[ ! "$domain" ]]
then
	read -p "Site Domain: " domain
fi

sites-pager -m prod -d "${domain}" -e staging -l "$(dirname $(pwd))" —staticdirs 'src/.tmp' —templatedir 'src/templates'
