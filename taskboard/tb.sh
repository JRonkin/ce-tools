tasks=()
selection=0
active=-1

while :
do
	clear
	printf "\
=========================================================
| Q: Quit     | N: New      | M: Minimize | X: Close    |
| [Enter]: Switch to Selection                          |
|-------------------------------------------------------|
"
for ((i = 0; i < ${#tasks[@]}; i++))
do
	if [[ $selection = $i ]]; then s=">"; else s=" "; fi
	if [[ $active = $i ]]; then a="*"; else a=" "; fi
	printf "\
| $s$a%s |
" "$(echo "${tasks[i]}                                                   " | sed "s/\(.\{51\}\).*/\1/")"
done
	printf "\
=========================================================
"

	read -n 1 input
	case "$( echo $input | tr a-z A-Z )" in

		"Q" )
			clear
			break
			;;

		"N" )
			clear
			read -p "GitHub URL: " giturl
			if [[ "$giturl" =~ .*github\.com\/[^/]+\/([^/]+).* ]]
			then
				repo=${BASH_REMATCH[1]}
			else
				printf "Invalid URL:\n$giturl\n\n> Return to TaskBoard"
				read -n 1
				continue
			fi
			read -p "JIRA Item URL: " jiraurl
			if [[ "$jiraurl" =~ .*selectedIssue=([^\&]+).* ]]
			then
				jiranum=${BASH_REMATCH[1]}
			else
				printf "No JIRA number found -- select an issue and copy the URL\n\n> Return to TaskBoard"
				read -n 1
				continue
			fi
			selection=${#tasks[*]}
			tasks[${#tasks[*]}]="$jiranum   $repo"
			./quickswap.sh -n giturl jiraurl
			;;

		"" )
			read -n 2 -t 1 input2
			case $input2 in
				"[A" )
					if [[ $selection -gt 0 ]]
					then
						selection=$(( $selection - 1 ))
					else
						selection=$(( ${#tasks[*]} - 1 ))
					fi
					;;
				"[B" )
					if [[ $selection -lt $(( ${#tasks[*]} - 1 )) ]]
					then
						selection=$(( $selection + 1 ))
					else
						selection=0
					fi
					;;
			esac
			;;

		"" )
			active=$selection
			;;

	esac
done