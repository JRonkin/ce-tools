#!/usr/bin/env bash
domain="$1"

if [ ! "$domain" ]
then
	read -p "Site domain: " domain
fi

curl -L -H 'Authorization: Basic dGVzdDp0ZXN0' "${domain}/sitemap.xml" 2>/dev/null | grep '<loc>' | sed -E 's/.*<loc>(.*)<\/loc>.*/\1/g'