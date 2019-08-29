folder="$1"
jiranum="$2"
repo="$3"
position="$4"
size="$5"

[ "$position" ] || position='279, 23'
[ "$size" ] || size='1331, 1027'

code "$folder"
