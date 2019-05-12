load_items() {
	local directory="$1"
	local name
	local symbol

	while read dir
	do
		name=
		symbol=
		source "${dir}.taskboard" 2>/dev/null

		echo "${symbol}$(basename "$dir")   ${name}"
	done <<< "$(ls -d ${directory}*/)"
}

# Menu Functions

new_task() {
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
			return
		fi
	fi

	read -p "Message: " name

	read -p "GitHub URL (blank for none): " gitUrl
	repo=""
	if [[ "$gitUrl" =~ .*github\.com\/[^/]+\/([^/]+).* ]]
	then
		repo="${BASH_REMATCH[1]}"
	fi

	# Start new task
	clear_menu
	new "$name" "$jiranum" "$repo"


	# Switch active task to new task
	if [ "$active" ]
	then
		deactivate "$active" &
		../timelog/timelog.sh "$active" end
	fi
	active="${jiranum}   ${name}"

	# Start timelog
	../timelog/timelog.sh "$active" start
}

quit() {
	clear_menu

	# Remove custom title
	osascript -e 'tell app "Terminal" to set custom title of 1st window whose name contains "TaskBoard" to "Terminal"' &

	exit
}

# PROGRAM START

# Set window title
osascript -e 'tell app "Terminal" to set custom title of front window to "TaskBoard"' &

# Set up directory and files
cd "$(dirname "${BASH_SOURCE[0]}")"
source taskswap.sh
source ../common/menu.sh
mkdir -p ../appdata/taskboard

# Read TaskSwap settings from config file
[ -f ../appdata/taskboard/taskswap.config ] && source ../appdata/taskboard/taskswap.config

if [ ! "$taskdir" ]
then
	taskdir="${HOME}/items/"
fi
mkdir -p "$taskdir"

selected=0

while :
do
	menu '\
Q: Quit TaskBoard | N: New Task       | X: Close Selected
[Enter]: Activate/Deactivate Selected | R: Reload Selected
M: More Options' "$(load_items "$taskdir")" $selected 'Q'

	case "$menu_key" in
		'Q' ) quit;;
	esac
done
