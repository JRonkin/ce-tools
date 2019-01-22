# Save terminal state
original_tty_state="$(stty -g)"

clean_exit() {
	# Remove custom title
	osascript -e 'tell app "Terminal" to set custom title of every window whose name contains "TaskBoard" to ""' &

	# Restore the screen and cursor
	tput rmcup
	tput cnorm

	# Restore Terminal state
	stty $original_tty_state

	exit
}

# Run clean_exit if interrupted
trap clean_exit EXIT INT SIGHUP SIGINT SIGQUIT SIGTERM

# Set window title
osascript -e 'tell app "Terminal" to set custom title of front window to "TaskBoard"' &

# Set up directory and files
cd "$(dirname "${BASH_SOURCE[0]}")"
source taskswap.sh
mkdir -p ../appdata/taskboard
touch ../appdata/taskboard/tasks

# Read TaskSwap settings from config file
touch ../appdata/taskboard/taskswap.config
source ../appdata/taskboard/taskswap.config

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
			read -sn 2 -t 1 input
			tput el1
			case "$input" in
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
				../timelog/timelog.sh "${tasks[$active]}" end
			fi
			break
		;;

		# New Task
		"N" )
			# Get input
			clear
			tput cnorm
			read -p "JIRA URL or Number: " jiraurl
			if [[ "$jiraurl" =~ .*yexttest\.atlassian\.net\/browse\/([^/#\?]+).* ]]
			then
				jiranum="${BASH_REMATCH[1]}"
			else
				if [[ "$jiraurl" =~ ^[A-Za-z]+-[0-9]+$ ]]
				then
					jiranum="$jiraurl"
				else
					tput civis
					printf "Invalid URL or JIRA Number:\n$jiraurl\n\n> Return to TaskBoard"
					read -sp ""
					continue
				fi
			fi
			read -p "GitHub URL or Message: " gitOrMsg
			tput civis
			repo=""
			message=""
			if [[ "$gitOrMsg" =~ .*github\.com\/[^/]+\/([^/]+).* ]]
			then
				repo="${BASH_REMATCH[1]}"
			else
				message=" $gitOrMsg"
			fi
			# Start new task
			tput rmcup
			new "$jiranum" "$repo"
			tput smcup
			tput clear
			# Add new task to list
			selected=${#tasks[*]}
			tasks[${#tasks[*]}]="${jiranum}   ${repo}${message}"
			# Switch active task to new task
			if [ $active -gt -1 ]
			then
				deactivate "${tasks[$active]}" &
				../timelog/timelog.sh "${tasks[$active]}" end
			fi
			active=$selected
			# Save task and start timelog
			echo "${tasks[$active]}" >> ../appdata/taskboard/tasks
			../timelog/timelog.sh "${tasks[$active]}" start
		;;

		# Close Selected
		"X" )
			if [ ${#tasks[*]} -gt 0 ]
			then
				close "${tasks[$selected]}" &
				# Remove task from saved task list
				sed -i "" "/${tasks[$selected]}/d" ../appdata/taskboard/tasks
				# If closing active task, end timelog and unset active; else adjust active
				if [ $active = $selected ]
				then
					../timelog/timelog.sh "${tasks[$active]}" end
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
			fi
		;;

		# Enter
		"" )
			# Deactivate active task and activate selected task
			if [ ${#tasks[*]} -gt 0 ]
			then
				if [ $active -gt -1 ]
				then
					deactivate "${tasks[$active]}" &
					../timelog/timelog.sh "${tasks[$active]}" end
				fi
				if [ $selected = $active ]
				then
					active=-1
				else
					activate "${tasks[$selected]}" &
					active=$selected
					../timelog/timelog.sh "${tasks[$active]}" start
				fi
			fi
		;;

		# More Options
		"M" )
			clear
			printf "\
[Enter]: Return to TaskBoard
E: Enable/Disable TaskSwap
S: Set Current Window Positions as Default
T: TimeReport
"
			tput el
			read -sn 1 input
			tput el1
			case "$(echo "$input" | tr a-z A-Z)" in
				# Options for TaskBoard to Enable or Disable Apps
				"E" )
					while :
					do
						clear
						printf "\
[Enter]: Return to TaskBoard
1: %s Atom
2: %s Chrome
3: %s Terminal
" "$(sed 's/^$/Enable/;s/^true$/Disable/' <<< "$enableAtom")" "$(sed 's/^$/Enable/;s/^true$/Disable/' <<< "$enableChrome")" "$(sed 's/^$/Enable/;s/^true$/Disable/' <<< "$enableTerminal")"
					
						tput el
						read -sn 1 input
						tput el1
						case "$input" in
							"1" )
								enableAtom="$(sed 's/^true$/false/;s/^$/true/;s/^false$//' <<< "$enableAtom")"
							;;

							"2" )
								enableChrome="$(sed 's/^true$/false/;s/^$/true/;s/^false$//' <<< "$enableChrome")"
							;;

							"3" )
								enableTerminal="$(sed 's/^true$/false/;s/^$/true/;s/^false$//' <<< "$enableTerminal")"
							;;

							* )
								break
							;;
						esac
					done

					echo "enableAtom='$enableAtom'" > ../appdata/taskboard/taskswap.config
					echo "enableChrome='$enableChrome'" >> ../appdata/taskboard/taskswap.config
					echo "enableTerminal='$enableTerminal'" >> ../appdata/taskboard/taskswap.config
				;;

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
					clear
				;;

				# Run TimeReport
				"T" )
					clear
					tput cnorm
					read -p "Start Date (format yyyy-mm-dd; leave blank for today): " date
					read -p "End Date (format yyyy-mm-dd; leave blank for same as start): " endDate

					if [ $active -gt -1 ]
					then
						../timelog/timelog.sh "${tasks[$active]}" end
					fi

					../timelog/timereport.sh "$date" "$endDate"

					if [ $active -gt -1 ]
					then
						../timelog/timelog.sh "${tasks[$active]}" start
					fi

					tput civis
					printf "\n\n> Return to TaskBoard"
					read -sp ""
					tput clear
				;;
			esac
		;;
	esac
done
