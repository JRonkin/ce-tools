cd "$(dirname "${BASH_SOURCE[0]}")"
source jira-auth.sh
source timefuncs.sh
mkdir -p ../appdata/timelog/logs

usage="Usage: timesum.sh [-hn] [-d decimals] [-r round_to] [-j [-u jira_user [-t jira_token]]] [date] [end date]"
definitions=(""
	"-h = help"
	"-n = no intermediate rounding (displayed times may not sum to total)"
	"-d decimals = number of decimal places to show (default 2)"
	"-r round_to = round to the nearest multiple of roundto (default 0.25)"
	""
	"-j = log time to JIRA (log messages must start with JIRA number, e.g. PC-12345)"
	"-u jira_user = JIRA username (your Yext email address)"
	"-t jira_token = JIRA Api Token -- https://id.atlassian.com/manage/api-tokens"
	""
	"date = date to summarize, in yyyy-mm-dd format (default today)"
	"end date = end of range to summarize (leave out for single date)"
"")

jira=""
apiToken=""
username=""
unrounded=""
decimals=2
roundto=0.25

while getopts "hntud:r:" opt
do
	case "$opt" in
		"j" )
			jira="-j"
		;;

		"h" )
			echo "${usage}"
				for i in "${definitions[@]}"
				do
					echo "$i"
				done
			exit
		;;

		"n" )
			unrounded="-n"
		;;

		"u" )
			username="$OPTARG"
		;;

		"t" )
			apiToken="$OPTARG"
		;;

		"d" )
			decimals="$OPTARG"
			if [[ ! "$decimals" =~ ^[0-9]+$ ]]
			then
				echo "Error: invalid number of decimal places"
				./timereport.sh -h
				exit 1
			fi
		;;

		"r" )
			roundto="$OPTARG"
			if [[ ! "$roundto" =~ ^[0-9]*\.?[0-9]*$ ]] || [[ "$roundto" =~ ^0*\.?0*$ ]]
			then
				echo "Error: invalid 'roundto' value"
				./timereport.sh -h
				exit 1
			fi
		;;

		* )
			exit 1
		;;
	esac
done

if [ ! "$username" ]
then
	apiToken=""
fi

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

while read epoch
do
	file="../appdata/timelog/logs/$(epoch2date $epoch).log"
	if [ -f "$file" ]
	then
		linetype="msg"
		while read line
		do
			case "$linetype" in
				"msg" )
					index="$(cksum <<< "$line" | cut -d " " -f 1)"
					if [ ! "${messages[$index]}" ]
					then
						indices[${#indices[*]}]=$index
						messages[$index]="$line"
					fi
					linetype="time"
				;;

				"time" )
					while read -d " " period
					do
						sums[$index]=$(( ${sums[$index]} + $(timediff ${period/-/ }) ))
					done <<< "${line} "
					linetype="skip"
				;;

				"skip" )
					linetype="msg"
				;;
			esac
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

if [ ! "$jira" ]
then
	read -p "Log to JIRA? You can edit on JIRA after submitting. (y/N) " jira
	if [[ ! "$jira" =~ ^[Yy]([Ee][Ss])?$ ]]
	then
		jira=""
	fi
fi

if [ "$jira" ]
then
	jira-auth "$username" "$apiToken"

	if [ "$endDate" = "$date" ]
	then
		for index in ${indices[@]}
		do
			roundedHours=$(round $(seconds2hours "${sums[$index]}") $roundto $decimals)
			jiranum=$(echo "${messages[$index]}" | cut -d " " -f 1)
			if [ ! $roundedHours = 0 ] && [[ "$jiranum" =~ ^[A-Z]+-[0-9]+$ ]]
			then
				./jirasubmit.sh -t "$apiToken" -u "$username" "$jiranum" "$roundedHours" "$date"
			fi
		done
	else
		while read epoch
		do
			./timereport $unrounded -d "$decimals" -r "$roundto" -j -u "$username" -t "$token" "$(epoch2date $epoch)"
		done <<< "$(seq -f %f $(date2epoch $date) 86400 $(date2epoch $endDate) | cut -d . -f 1) "
	fi
fi
