while read filename
do
  cat "$filename" | sort -u > "${filename}.tmp"
  mv "${filename}.tmp" "$filename"

  conflicts="$(cat "$filename" | sed 's/^\([^,]*\),.*$/\1/' | uniq -d)"
  if [ "$conflicts" ]
  then
    >&2 echo "$(echo "$conflicts" | wc -l | tr -d ' ') CONFLICTS in '${filename}':"
    >&2 echo "$conflicts"
  fi
done <<< "$(ls redirects*.csv)"
