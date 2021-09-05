folder="$1"
jiranum="$2"
repo="$3"

if [ "$repo" ]
then
  atom "${folder}/${repo}"    
fi
