folder="$1"
jiranum="$2"
repo="$3"
position="$4"
size="$5"

if [ "$repo" ]
then
  atom "${folder}/${repo}"
  sleep 1
  ./setbounds.sh "$folder" "$jiranum" "$repo" "$position" "$size"
fi
