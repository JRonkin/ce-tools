cd "$(dirname "${BASH_SOURCE[0]}")"
source timefuncs.sh
mkdir -p ../appdata/timelog/logs

usage="Usage: timelog.sh [-h] (item) (command) [args]"
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
					echo "$i"
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
file="../appdata/timelog/logs/$(date +%Y-%m-%d).log"
touch "$file"

case "$command" in
	"s" | "start" )
		if [ "$#" -lt 3 ]
		then
			time="$(date +%T)"
		else
			time="$(formattime "$3")"
		fi
		linenum="$(grep -Fn "$item" "$file" | cut -d : -f 1)"
		if [ "$linenum" ]
		then
			sed -i "" "$(($linenum + 1))s/ \$/ ${time}-/" "$file"
		else
			echo "$item" >> "$file"
			echo "${time}-" >> "$file"
			echo "" >> "$file"
		fi
	;;

	"e" | "end" )
		linenum="$(grep -Fn "$item" "$file" | cut -d : -f 1)"
		if ! [ "$linenum" ]
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
		sed -i "" "$(($linenum + 1))s/-\$/-${time} /" "$file"
	;;

	"f" | "from" )
		if [ "$#" -lt 3 ]
		then
			echo "Error: incorrect number of arguments."
			echo "$command_from"
			exit 1
		fi
		if [ "$#" -lt 4 ]
		then
			time="$(date +%T)"
		else
			time="$4"
		fi
		./timelog.sh "$item" start "$time"
		./timelog.sh "$item" end "$(timeaddhours "$time" "$3")"
	;;

	"t" | "to" )
		if [ "$#" -lt 3 ]
		then
			echo "Error: incorrect number of arguments."
			echo "$command_to"
			exit 1
		fi
		if [ "$#" -lt 4 ]
		then
			time="$(date +%T)"
		else
			time="$4"
		fi
		./timelog.sh "$item" start "$(timeaddhours "$time" "-${3}")"
		./timelog.sh "$item" end "$time"
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
