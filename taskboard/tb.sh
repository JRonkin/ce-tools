# Set window title
osascript -e 'tell app "Terminal" to set custom title of front window to "TaskBoard"' &

# Set up directory and files
cd "$(dirname "${BASH_SOURCE[0]}")"
source taskswap.sh
mkdir -p ../appdata/taskboard
touch ../appdata/taskboard/tasks

# Initialize tasks
tasks=()
selected=0
active=-1

# Read in saved tasks from file
while read line
do
	tasks[${#tasks[*]}]="$line"
	deactivate "$line" &
done < ../appdata/taskboard/tasks

# Save and clear the screen
tput smcup
tput clear
tput civis

# Program loop
while :
do
	# Draw GUI
	tput home
	printf "\
=============================================================
| Q: Quit TaskBoard | N: New Task       | X: Close Selected |
| [Enter]: Activate/Deactivate Selected | M: More Options   |
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

	# Wait for input
	tput el
	read -sn 1 input
	tput el1
	case "$(echo "$input" | tr a-z A-Z)" in

		# Arrow key
		"" )
			read -sn 2 -t 1 input2
			tput el1
			case $input2 in
				# Up arrow
				"[A" )
					if [ $selected -gt 0 ]
					then
						(( --selected ))
					else
						selected=$(( ${#tasks[*]} - 1 ))
					fi
					;;
				# Down Arrow
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

		# Quit Taskboard
		"Q" )
			if [ $active -gt -1 ]
			then
				deactivate "${tasks[$active]}" &
				../timelog/tl.sh "${tasks[$active]}" end
			fi
			break
		;;

		# New Task
		"N" )
			# Get input
			clear
			tput cnorm
			read -p "JIRA URL: " jiraurl
			if [[ "$jiraurl" =~ .*yexttest\.atlassian\.net\/browse\/([^/#\?]+).* ]]
			then
				jiranum="${BASH_REMATCH[1]}"
			else
				tput civis
				printf "Invalid URL:\n$jiraurl\n\n> Return to TaskBoard"
				read -sp ""
				continue
			fi
			read -p "GitHub URL: " giturl
			tput civis
			if [[ "$giturl" =~ .*github\.com\/[^/]+\/([^/]+).* ]]
			then
				repo="${BASH_REMATCH[1]}"
			else
				printf "Invalid URL:\n$giturl\n\n> Return to TaskBoard"
				read -sp ""
				continue
			fi
			# Start new task
			tput rmcup
			new "$repo" "$jiranum"
			tput smcup
			tput clear
			# Add new task to list
			selected=${#tasks[*]}
			tasks[${#tasks[*]}]="$jiranum   $repo"
			# Switch active task to new task
			if [ $active -gt -1 ]
			then
				deactivate "${tasks[$active]}" &
				../timelog/tl.sh "${tasks[$active]}" end
			fi
			active=$selected
			# Save task and start timelog
			echo "${tasks[$active]}" >> ../appdata/taskboard/tasks
			../timelog/tl.sh "${tasks[$active]}" start
		;;

		# Close Selected
		"X" )
			close "${tasks[$selected]}" &
			# Remove task from saved task list
			sed -i "" "/${tasks[$selected]}/d" ../appdata/taskboard/tasks
			# If closing active task, end timelog and unset active; else adjust active
			if [ $active = $selected ]
			then
				../timelog/tl.sh "${tasks[$active]}" end
				active=-1
			else
				if [ $active -gt $selected ]
				then
					(( --active ))
				fi
			fi
			# Remove task and adjust selected
			tasks=("${tasks[@]:0:$selected}" "${tasks[@]:$(( $selected + 1 )):${#tasks[*]}}")
			if [ $selected = ${#tasks[*]} ]; then (( --selected )); fi
		;;

		# Enter
		"" )
			# Deactivate active task and activate selected task
			if [ ${#tasks[*]} -gt 0 ]
			then
				if [ $active -gt -1 ]
				then
					deactivate "${tasks[$active]}" &
					../timelog/tl.sh "${tasks[$active]}" end
				fi
				if [ $selected = $active ]
				then
					active=-1
				else
					activate "${tasks[$selected]}" &
					active=$selected
					../timelog/tl.sh "${tasks[$active]}" start
				fi
			fi
		;;

		# More Options
		"M" )
			clear
			printf "\
[Enter]: Return to TaskBoard
S: Set Current Window Positions as Default
"
			tput el
			read -sn 1 input
			tput el1
			case "$(echo "$input" | tr a-z A-Z)" in
				# Set Current Window Positions as Default 
				"S" )
					if [ $active -gt -1 ]
					then
						save-window-bounds "${tasks[$active]}"
						clear
						printf "The current window positions and sizes have been set as default.\n\n> Return to TaskBoard"
						read -sp ""
					else
						clear
						printf "You must have an active task to save window positions.\n\n> Return to TaskBoard"
						read -sp ""
					fi
				;;
			esac
		;;

	esac
done

# Restore the screen and cursor
tput rmcup
tput cnorm
