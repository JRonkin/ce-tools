# Helper Functions

load_items() {
	local directory="$1"
	local name
	local symbol

	if [ "$(ls "$directory")" ]
	then
		while read dir
		do
			name=
			symbol=
			source "${dir}.taskboard" 2>/dev/null

			echo "${symbol}$(basename "$dir")   ${name}"
		done <<< "$(ls -d "$directory"*/)"
	fi
}

activate_task() {
	local jiranum="$1"
	local repo="$2"
	local name="$3"

	activate "$jiranum" "$repo" "$name" &
	../timelog/timelog.sh "${jiranum} ${name}" start

	active_jira="$jiranum"
	active_repo="$repo"
	active_name="$name"
}

deactivate_task() {
	local jiranum="$1"
	local repo="$2"
	local name="$3"

	deactivate "$jiranum" "$repo" "$name" &
	../timelog/timelog.sh "${jiranum} ${name}" end

	active_jira=
	active_repo=
	active_name=
}


# Main Menu Functions

select_task() {
	case "${menu_value:0:1}" in
		'·' )
			[ "$active_jira" ] && deactivate_task "$active_jira" "$active_repo" "$active_name"
			activate_task "$jiranum" "$repo" "$name"
		;;
		'*' )
			deactivate_task "$jiranum" "$repo" "$name"
		;;
	esac
}

quit() {
	[ "$active_jira" ] && deactivate_task "$active_jira" "$active_repo" "$active_name"

	# Remove custom title
	osascript -e 'tell app "Terminal" to set custom title of 1st window whose name contains "TaskBoard" to "Terminal"' &

	clear_menu

	exit
}

new_task() {
	local jiraurl
	local jiranum
	local name
	local gitUrl
	local repo

	clear
	tput cnorm
	stty echo

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
			stty -echo
			printf "Invalid URL or JIRA Number:\n$jiraurl\n\n> Return to TaskBoard"
			read -sp ""
			return
		fi
	fi

	read -p "Message: " name
	name="${name//\"/\\\"}"
	name="${name//\$/\\\"}"

	read -p "GitHub URL or Repo Name (blank for none): " gitUrl
	repo="$gitUrl"
	if [[ "$gitUrl" =~ .*github\.com\/[^/]+\/([^/]+).* ]]
	then
		repo="${BASH_REMATCH[1]}"
	fi

	# Start new task
	clear_menu
	new "$name" "$jiranum" "$repo"


	# Switch active task to new task
	[ "$active_jira" ] && deactivate_task "$active_jira" "$active_repo" "$active_name"
	active_jira="$jiranum"
	active_repo="$repo"
	active_name="$name"

	# Start timelog
	../timelog/timelog.sh "${active_jira} ${active_name}" start
}

close_task() {
	if [ "$jiranum" ]
	then
		close "$(echo "$jiranum" | cut -d ' ' -f 1)"
		../timelog/timelog.sh "${jiranum} ${name}" end
	fi
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

menu_selected=0

while :
do
	menu "\
Q: Quit TaskBoard | N: New Task       | X: Close Selected
[Enter]: Activate/Deactivate Selected | R: Reload Selected
M: More Options" "$(load_items "$taskdir")" $menu_selected 'Q' 'N' 'X' 'R' 'M'

	jiranum="$(echo "${menu_value:1}" | cut -d ' ' -f 1)"
	repo=
	name="$(echo "${menu_value:1} " | cut -d ' ' -f 4)"

	case "$menu_key" in
		'' ) select_task;;
		'Q' ) quit;;
		'N' ) new_task;;
		'X' ) close_task;;
		'R' ) ;;
		'M' ) ;;
	esac
done
