folder="$1"
jiranum="$2"
repo="$3"

bounds=($(osascript -e "tell app \"Google Chrome\" to get the bounds of the 1st window where the url of the 1st tab contains \".atlassian.net/browse/${jiranum}\"" | tr -d ','))

echo "${bounds[0]}, ${bounds[1]}|$(( ${bounds[2]} - ${bounds[0]} )), $(( ${bounds[3]} - ${bounds[1]} ))"
