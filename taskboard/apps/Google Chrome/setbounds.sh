folder="$1"
jiranum="$2"
repo="$3"
position="$4"
size="$5"

if [ "$position" ] && [ "$size" ]
then
  bounds="${position}, $(( ${position%,*} + ${size%,*} )), $(( ${position#*,} + ${size#*,} ))"

  osascript -e "tell app \"Google Chrome\" to set the bounds of the 1st window where the url of the 1st tab contains \".atlassian.net/browse/${jiranum}\" to {${bounds}}"
fi
