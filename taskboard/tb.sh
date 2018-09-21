osascript -e 'tell app "Terminal" to set custom title of front window to "TaskBoard"' &

cd $(dirname "${BASH_SOURCE[0]}")
source taskswap.sh
mkdir -p ../appdata/taskboard
touch ../appdata/taskboard/tasks

tasks=()
selected=0
active=-1

while read line
do
	tasks[${#tasks[*]}]="$line"
	deactivate "$line" &
done < ../appdata/taskboard/tasks

tput smcup
tput clear
tput civis

while :
do
	tput home
	printf "\
=============================================================
| Q: Quit TaskBoard | N: New Task       | X: Close Selected |
| [Enter]: Activate/Deactivate Selected                     |
|-----------------------------------------------------------|
"
for ((i = 0; i < ${#tasks[@]}; i++))
do
	if [ $selected = $i ]; then s=">"; else s=" "; fi
	if [ $active = $i ]; then a="*"; else a=" "; fi
	printf "\
| $s$a%s |
" "$(echo "${tasks[i]}                                                       " | sed "s/\(.\{55\}\).*/\1/")"
done
	printf "\
=============================================================
"

	tput el
	read -n 1 input
	tput el1
	case "$( echo $input | tr a-z A-Z )" in

		"Q" )
			break
			;;

		"N" )
			clear
			tput cnorm
			read -p "JIRA URL: " jiraurl
			if [[ "$jiraurl" =~ .*yexttest\.atlassian\.net\/browse\/([^/#\?]+).* ]]
			then
				jiranum=${BASH_REMATCH[1]}
			else
				tput civis
				printf "Invalid URL:\n$jiraurl\n\n> Return to TaskBoard"
				read -n 1
				continue
			fi
			read -p "GitHub URL: " giturl
			tput civis
			if [[ "$giturl" =~ .*github\.com\/[^/]+\/([^/]+).* ]]
			then
				repo=${BASH_REMATCH[1]}
			else
				printf "Invalid URL:\n$giturl\n\n> Return to TaskBoard"
				read -n 1
				continue
			fi
			tput rmcup
			new "$repo" "$jiranum"
			tput smcup
			tput clear
			selected=${#tasks[*]}
			tasks[${#tasks[*]}]="$jiranum   $repo"
			echo "$jiranum   $repo" >> ../appdata/taskboard/tasks
			if [ $active -gt -1 ]
			then
				deactivate "${tasks[$active]}" &
			fi
			active=$selected
			;;

		"X" )
			close "${tasks[$selected]}" &
			sed -i "" "/${tasks[$selected]}/d" ../appdata/taskboard/tasks
			tasks=("${tasks[@]:0:$selected}" "${tasks[@]:$(( $selected + 1 )):${#tasks[*]}}")
			if [ $active = $selected ]
			then
				active=-1
			else
				if [ $active -gt $selected ]
				then
					(( --active ))
				fi
			fi
			if [ $selected = ${#tasks[*]} ]; then (( --selected )); fi
			;;

		"" )
			read -n 2 -t 1 input2
			tput el1
			case $input2 in
				"[A" )
					if [ $selected -gt 0 ]
					then
						(( --selected ))
					else
						selected=$(( ${#tasks[*]} - 1 ))
					fi
					;;
				"[B" )
					if [ $selected -lt $(( ${#tasks[*]} - 1 )) ]
					then
						(( ++selected ))
					else
						selected=0
					fi
					;;
			esac
			;;

		"" )
			if [ ${#tasks[*]} -gt 0 ]
			then
				if [ $active -gt -1 ]
				then
					deactivate "${tasks[$active]}" &
				fi
				if [ $selected = $active ]
				then
					active=-1
				else
					activate "${tasks[$selected]}" &
					active=$selected
				fi
			fi
			;;

	esac
done

tput rmcup
tput cnorm