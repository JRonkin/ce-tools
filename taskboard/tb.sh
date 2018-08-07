selection=0

while :
do
	clear
	printf "\
======================================================
| Q: Quit QS  | N: New      | M: Minimize | X: Close |
| [Enter]: Switch to Selection                       |
|----------------------------------------------------|
======================================================
"

	read -n 1 input
	case "$( echo $input | tr a-z A-Z )" in

		"Q" )
			break
			;;

		"N" )
			clear
			read -p "Git Clone URL (SSH): " giturl
			if [[ giturl =~ "git@github\.com:.+/(.+)\.git" ]]
			then
				repo=${BASH_REMATCH[1]}
			else
				echo "Invalid URL"
				read -n 1
				continue
			fi
			read -p "JIRA Item URL: " jiraurl
			if [[ jiraurl =~ ".*selectedIssue=([^\&]+).*" ]]
			then
				jiranum=${BASH_REMATCH[1]}
			else
				echo "No JIRA number found -- please select an issue and copy the URL."
				read -n 1
				continue
			fi
			./quickswap.sh -n giturl jiraurl
			;;

		"" )
			read -n 2 -t 1 input2
			case $input2 in
				"[A" )
					echo "UP"
					;;
				"[B" )
					echo "DOWN"
					;;
			esac
			;;

	esac
done