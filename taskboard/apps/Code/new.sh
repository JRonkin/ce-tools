folder="$1"
jiranum="$2"
repo="$3"
bounds="$4"

if [ ! "$bounds" ]
then
  bounds='279, 23, 1610, 1050'
fi

code "$folder"
