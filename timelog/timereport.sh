cd $(dirname "${BASH_SOURCE[0]}")
source timefuncs.sh
mkdir -p ../appdata/timelog/logs

usage="Usage: timesum.sh [-hu] [-d (decimals)] [-r (roundto)] [date] [end date]"
definitions=("" "-d (decimals) = number of decimal places to show (default 2)" "-r (roundto) = round to the nearest multiple of roundto (default 0.25)" "-h = help" "-u = use unrounded times for total (displayed times may not sum to total)" "" "date = date to summarize, in yyyy-mm-dd format (default today)" "end date = end of range to summarize (leave out for single date)")

unrounded=""
decimals=2
roundto=0.25

while getopts "hud:r:" opt
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

		"u" )
			unrounded=true
		;;

		"d" )
			decimals="$OPTARG"
			if [[ ! "$decimals" =~ ^[0-9]+$ ]]
			then
				echo "Error: invalid number of decimal places"
				timereport.sh -h
				exit 1
			fi
		;;

		"r" )
			roundto="$OPTARG"
			if [[ ! "$roundto" =~ ^[0-9]*\.?[0-9]*$ ]] || [[ "$roundto" =~ ^0*\.?0*$ ]]
			then
				echo "Error: invalid 'roundto' value"
				timereport.sh -h
				exit 1
			fi
		;;

		* )
			exit 1
		;;
	esac
done

shift $((OPTIND-1))

if [ "$1" ]
then
	date="$(date -ju -f "%Y-%m-%d" "$1" "+%Y-%m-%d")"
	if [ ! "$date" ]
	then
		echo "Error: invalid date. Date must be in the format yyyy-mm-dd"
		exit 1
	fi
else
	date="$(date "+%Y-%m-%d")"
fi

if [ "$2" ]
then
	endDate="$(date -ju -f "%Y-%m-%d" "$2" "+%Y-%m-%d")"
	if [ ! "$endDate" ]
	then
		echo "Error: invalid date. Date must be in the format yyyy-mm-dd"
		exit 1
	fi
else
	endDate="$date"
fi

while read -d " " epoch
do 
	file="../appdata/timelog/logs/$(epoch2date $epoch).log"
	if [ -f "$file" ]
	then
		while read line
		do
			if [[ "$line" =~ ^[^\|]{20}\| ]]
			then
				message="${line:22}"
				index="$(cksum <<< "$message" | cut -d " " -f 1)"
				if [ ! "${messages[$index]}" ]
				then
					indices[${#indices[*]}]=$index
					messages[$index]="$message"
				fi
				sums[$index]=$(( ${sums[$index]} + $(timediff $(echo "${line//-}" | cut -d "|" -f 1) ) ))
			fi
		done < "$file"
	fi
done <<< "$(seq -f %f $(date2epoch $date) 86400 $(date2epoch $endDate) | cut -d . -f 1) "

totalhours=0
for index in ${indices[@]}
do
	hours=$(seconds2hours "${sums[$index]}")
	roundedHours=$(round $hours $roundto $decimals)
	if [ ! $roundedHours = 0 ]
	then
		echo "${roundedHours} hours: ${messages[$index]}"
	fi
	if [ $unrounded ]
	then
		totalhours=$(bc <<< "${totalhours} + ${hours}")
	else
		totalhours=$(bc <<< "${totalhours} + ${roundedHours}")
	fi
done
sed 's/^\./0\./' <<< "${totalhours} hours total"