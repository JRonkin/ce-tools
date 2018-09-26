cd $(dirname "${BASH_SOURCE[0]}")
source timefuncs.sh
mkdir -p ../appdata/timelog

usage="Usage: timesum.sh [-h] [date]"
definitions=("" "-h = help" "" "date = date to summarize, in yyyy-mm-dd format")

while getopts "h" opt
do
	case "$opt" in
		"h" )
			echo "${usage}"
				for i in "${definitions[@]}"
				do
					echo "$i"
				done
			exit
		;;

		* )
			exit 1
		;;
	esac
done

if [ "$1" ]
then
	date="$(date -ju -f "%Y-%m-%d" "$1" "+%Y-%m-%d")"
	if ! [ "$date" ]
	then
		echo "Error: invalid date. Date must be in the format yyyy-mm-dd"
		exit 1
	fi
else
	date="$(date "+%Y-%m-%d")"
fi

file="../appdata/timelog/${date}.log"
if ! [ -f "$file" ]
then
	echo "Error: no time log found for ${date}"
	exit 1
fi

while read line
do
	if [[ "$line" =~ ^[^\|]{20}\| ]]
	then
		message="${line:22}"
		index="$(cksum <<< "$message" | cut -d " " -f 1)"
		if ! [ "${messages[$index]}" ]
		then
			indices[${#indices[*]}]=$index
			messages[$index]="$message"
		fi
		sums[$index]=$(( ${sums[$index]} + $(timediff $(echo "${line//-}" | cut -d "|" -f 1) ) ))
	fi
done < "$file"

totalhours=0
for index in ${indices[@]}
do
	hours=$(bc <<< "scale=2; $(bc <<< "scale=0; ($(seconds2hours "${sums[$index]}") * 4 + 0.5) / 1") / 4")
	echo "$(sed 's/^\./0\./; s/^0$/0.00/' <<< ${hours}) hours: ${messages[$index]}"
	totalhours=$(bc <<< "${totalhours} + ${hours}")
done
echo "${totalhours} hours total"