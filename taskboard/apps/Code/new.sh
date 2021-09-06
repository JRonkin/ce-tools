folder="$1"
jiranum="$2"
repo="$3"
position="$4"
size="$5"

open -a 'Visual Studio Code' "$folder"
sleep 1
./setbounds.sh "$folder" "$jiranum" "$repo" "$position" "$size"
