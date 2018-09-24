formattime() {
	if [[ "$1" =~ ^((0?|1)[0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?$ ]]
	then
		time="$1"
		if [[ "$time" =~ ^.: ]]
		then
			time="0${time}"
		fi
		if ! [[ "$time" =~ :..: ]]
		then
			time="${time}:00"
		fi
	else
		>&2 echo "Error: '$1' invalid time format. Time must be 24-hour in the format 15:04"
		exit 1
	fi

	echo "$time"
}


cd $(dirname "${BASH_SOURCE[0]}")
mkdir -p ../appdata/timelog

usage="Usage: tl [-h] (item) (command) [args]"
command_start="s, start - args: [time] -- Log a start at a 24-hour time formatted as 15:04 (default to current time)"
command_end="e, end - args: [time] -- Log an end at a 24-hour time formatted as 15:04 (default to current time)"
command_from="f, from - args: (duration) [time] -- Log a duration of time, in hours, starting at a 24-hour time formatted as 15:04 (default to current time)"
command_to="t, to - args: (duration) [time] -- Log a duration of time, in hours, ending at a 24-hour time formatted as 15:04 (default to current time)"
definitions=("" "-h = help" "" "item = item for log (used for matching starts to ends)" "" "commands:" "${command_start}" "${command_end}" "${command_from}" "${command_to}")


while getopts "h" opt
do
	case "$opt" in
		"h" )
			echo "${usage}"
				for i in "${definitions[@]}"
				do
					echo $i
				done
			exit
		;;

		* )
			exit 1
		;;
	esac
done

if [ "$#" -lt 2 ]
then
  echo "Error: incorrect number of arguments."
  echo "${usage}"
  exit 1
fi

item="$1"
command="$2"
file="../appdata/timelog/$(date +%Y-%m-%d).log"

case "$command" in
	"s" | "start" )
		if [ "$#" -lt 3 ]
		then
			time="$(date +%T)"
		else
			time="$(formattime "$3")"
		fi
		echo "${item} ${time} - " >> "$file"
	;;

	"e" | "end" )
		linenum="$(grep -Fn "$item" "$file" | grep -e "- $" | head -n 1 | cut -d : -f 1)"
		if [[ linenum = "" ]]
		then
			echo "Error: no open start time found for '$item'"
			exit 1
		fi
		if [ "$#" -lt 3 ]
		then
			time="$(date +%T)"
		else
			time="$(formattime "$3")"
		fi
		sed -i "" "${linenum}s/\(.*\)/\1${time}/" "$file"
	;;

	"f" | "from" )
		echo "TODO: Implement 'from'"
		exit
	;;

	"t" | "to" )
		echo "TODO: Implement 'to'"
		exit
	;;

	* )
		echo "Unknown command. Commands:"
		echo "    ${command_start}"
		echo "    ${command_end}"
		echo "    ${command_from}"
		echo "    ${command_to}"
		exit 1
	;;
esac