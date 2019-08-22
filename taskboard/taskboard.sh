# Helper Functions

save-config() {
  echo "ITEMS_DIR='${ITEMS_DIR}'" > ../appdata/taskboard/taskswap.config

  for app in "${apps[@]}"
  do
    if [ ${enabledApps[$(hash "$app")]} ]
    then
      echo "enabledApps[$(hash "$app")]=true" >> ../appdata/taskboard/taskswap.config
    fi
  done
}

list-items() {
  local directory="$1"
  local name
  local symbol
  local repo

  for item in $(ls "$directory")
  do
    name=
    symbol=' '
    repo=
    source "${directory}/${item}/.taskboard" 2>/dev/null

    echo "${symbol}${item}   ${name}"
  done
}

list-repos() {
  local directory="$1"
  local currentRepo="$2"

  for dir in $(find "$directory" -type d -name '.git' -maxdepth 2)
  do
    local repo="$(basename "$(dirname "$dir")")"
    local symbol=' '
    [ "$repo" = "$currentRepo" ] && symbol='*'

    echo "${symbol}${repo}"
  done
}

timelog-message() {
  local jiranum="$1"
  local repo="$2"
  local name="$3"

  echo "${jiranum} ${name}" | sed 's/ *$//'
}

activate-task() {
  local jiranum="$1"
  local repo="$2"
  local name="$3"

  activate "$jiranum" "$repo" "$name"
  ../timelog/timelog.sh "$(timelog-message "$jiranum" "$repo" "$name")" start

  active_jira="$jiranum"
  active_repo="$repo"
  active_name="$name"
}

deactivate-task() {
  local jiranum="$1"
  local repo="$2"
  local name="$3"

  deactivate "$jiranum" "$repo" "$name"
  ../timelog/timelog.sh "$(timelog-message "$jiranum" "$repo" "$name")" end

  active_jira=
  active_repo=
  active_name=
}


# Main Menu Functions

quit() {
  [ "$active_jira" ] && deactivate-task "$active_jira" "$active_repo" "$active_name"

  clear-menu

  # Remove custom title
  echo -n -e "\033]0;\007"

  exit
}

apps-menu() {
  menu "$(timelog-message "$jiranum" "$repo" "$name")
[Enter]: Open App | X: Close App | Q: Return to TaskBoard" "$(
    for app in "${apps[@]}"
    do
      echo "$app"
    done
  )" 0 'X' 'Q'

  case "$menu_key" in
    '' ) new-app "$menu_value" "$jiranum" "$repo";;
    'Q' ) ;;
    'X' ) close-app "$menu_value" "$jiranum" "$repo";;
  esac
}

new-task() {
  local jiraurl
  local jiranum
  local name
  local gitUrl
  local repo

  clear
  tput cnorm
  stty echo

  read -p 'JIRA URL or Number: ' jiraurl
  if [[ "$jiraurl" =~ .*\.atlassian\.net\/browse\/([^/#?]+).* ]]
  then
    jiranum="${BASH_REMATCH[1]}"
  else
    if [[ "$jiraurl" =~ ^[A-Za-z]+-[0-9]+$ ]]
    then
      jiranum="$jiraurl"
    else
      tput civis
      stty -echo
      printf "Invalid URL or JIRA Number:\n${jiraurl}\n\n> Return to TaskBoard"
      read -sp ''
      return
    fi
  fi

  IFS= read -p 'Name: ' name
  name="${name//\"/\\\"}"
  name="${name//\$/\\\"}"

  read -p 'GitHub URL or Repo Name (blank for none): ' gitUrl
  repo="$gitUrl"
  if [[ "$gitUrl" =~ .*github\.com\/[^/]+\/([^/]+).* ]]
  then
    repo="${BASH_REMATCH[1]}"
  fi

  # Start new task
  clear-menu
  new "$name" "$jiranum" "$repo"


  # Switch active task to new task
  [ "$active_jira" ] && deactivate-task "$active_jira" "$active_repo" "$active_name"
  active_jira="$jiranum"
  active_repo="$repo"
  active_name="$name"

  # Start timelog
  ../timelog/timelog.sh "$(timelog-message "$jiranum" "$repo" "$name")" start
}

edit-task() {
  menu "\
N: Change Name
R: Change Repo" ' Return to TaskBoard' 0 'N' 'R'

  case "$menu_key" in
    'N' )
      clear
      tput cnorm
      stty echo

      echo "Current Name: ${name}"
      read -p 'New Name: ' name
      sed -i '' "s/^name=.*/name=\"${name}\"/" "${ITEMS_DIR}/${jiranum}/.taskboard"
    ;;
    'R' )
      while :
      do
        source "${ITEMS_DIR}/${jiranum}/.taskboard"
        menu '[Enter]: Select Repo | N: New Repo | X: Remove Repo' "$(list-repos "${ITEMS_DIR}/${jiranum}" "$repo")" 0 'N' 'X'
        case "$menu_key" in
          '' )
            sed -i '' "s/^repo=.*/repo=\"${menu_value:1}\"/" "${ITEMS_DIR}/${jiranum}/.taskboard"
            break
          ;;
          'N' )
            clear
            tput cnorm
            stty echo

            read -p 'GitHub URL or Repo Name: ' gitUrl
            repo="$gitUrl"
            if [[ "$gitUrl" =~ .*github\.com\/[^/]+\/([^/]+).* ]]
            then
              repo="${BASH_REMATCH[1]}"
            fi

            git clone --recurse-submodules -j8 "git@github.com:yext-pages/${repo}.git" "${ITEMS_DIR}/${jiranum}/${repo}"
          ;;
          'X' )
            if [ "${menu_value:1}" ]
            then
              trash "${ITEMS_DIR}/${jiranum}/${menu_value:1}"
            fi
          ;;
        esac
      done
    ;;
  esac
}

close-task() {
  if [ "$jiranum" ]
  then
    close "$(echo "$jiranum" | cut -d ' ' -f 1)"

    if [ "$jiranum" = "$active_jira" ]
    then
      ../timelog/timelog.sh "$(timelog-message "$jiranum" "$repo" "$name")" end

      active_jira=
      active_repo=
      active_name=
    fi
  fi
}

select-task() {
  case "${menu_value:0:1}" in
    ' ' )
      [ "$active_jira" ] && deactivate-task "$active_jira" "$active_repo" "$active_name"
      activate-task "$jiranum" "$repo" "$name"
    ;;
    '*' )
      deactivate-task "$jiranum" "$repo" "$name"
    ;;
  esac
}

more-options() {
  menu "\
E: Enable/Disable TaskSwap
I: Change Items Directory
S: Set Current Window Positions as Default
T: TimeReport" ' Return to TaskBoard' 0 'E' 'I' 'S' 'T'

  case "$menu_key" in
    'E' )
      menu_selected=0
      while :
      do
        menu '[Enter]: Enable/Disable App | Q: Save Preferences' "$(
          for app in "${apps[@]}"
          do
            local symbol=' '
            [ ${enabledApps[$(hash "$app")]} ] && symbol='*'
            echo "${symbol}${app}"
          done
        )" $menu_selected 'Q'

        [ "$menu_key" = 'Q' ] && break

        enabledApps[$(hash "${menu_value:1}")]=$([ ${enabledApps[$(hash "${menu_value:1}")]} ] || echo true)
      done

      save-config

    ;;

    # Change Items Directory
    'I' )
      clear
      tput cnorm
      stty echo

      echo "Default is ${HOME}/items/"
      echo 'Type the full name of the directory or leave blank to use default:'

      read ITEMS_DIR
      [ "$ITEMS_DIR" ] || ITEMS_DIR="${HOME}/items"
      ITEMS_DIR=${ITEMS_DIR%/}

      save-config
    ;;

    # Set Current Window Positions as Default
    'S' )
      if [ "$active_jira" ]
      then
        save-window-bounds "$active_jira" "$active_repo"
        clear
        printf "The current window positions and sizes have been set as default.\n\n> Return to TaskBoard"
        read -p ''
      else
        clear
        printf "You must have an active task to save window positions.\n\n> Return to TaskBoard"
        read -p ''
      fi
    ;;

    # TimeReport
    'T' )
      clear
      tput cnorm
      stty echo

      read -p 'Start Date (format yyyy-mm-dd; leave blank for today): ' date
      read -p 'End Date (format yyyy-mm-dd; leave blank for same as start): ' endDate

      [ "$active_jira" ] && ../timelog/timelog.sh "$(timelog-message "$jiranum" "$repo" "$name")" end

      ../timelog/timereport.sh "$date" "$endDate"

      [ "$active_jira" ] && ../timelog/timelog.sh "$(timelog-message "$jiranum" "$repo" "$name")" start

      tput civis
      stty -echo

      printf "\n\n> Return to TaskBoard"
      read -p ''
    ;;
  esac
}


# PROGRAM START

# Set window title
echo -n -e "\033]0;TaskBoard\007"

# Set up directory and files
cd "$(dirname "${BASH_SOURCE[0]}")"
source taskswap.sh
source ../common/menu.sh
mkdir -p ../appdata/taskboard

# Read TaskSwap settings from config file
[ -f ../appdata/taskboard/taskswap.config ] && source ../appdata/taskboard/taskswap.config

if [ ! "$ITEMS_DIR" ]
then
  clear
  echo 'Welcome to TaskBoard! Please choose a directory for item folders.'
  echo "Default is ${HOME}/items"
  echo 'Type the full name of the directory or leave blank to use default:'

  read ITEMS_DIR
  [ "$ITEMS_DIR" ] || ITEMS_DIR="${HOME}/items"
  ITEMS_DIR=${ITEMS_DIR%/}

  save-config
fi
mkdir -p "$ITEMS_DIR"

selected=0

while :
do
  menu "\
Q: Quit TaskBoard | A: Apps
N: New Task       | E: Edit Task      | X: Close Task
[Enter]: Activate/Deactivate Selected | M: More Options" "$(list-items "$ITEMS_DIR")" $selected 'Q' 'A' 'N' 'E' 'X' 'M'

  selected=$menu_selected
  jiranum="$(echo "${menu_value:1}" | cut -d ' ' -f 1)"
  repo=
  name=
  symbol=

  if [ "$menu_value" ]
  then
    source "${ITEMS_DIR}/${jiranum}/.taskboard"
  fi

  case "$menu_key" in
    '' ) select-task;;
    'Q' ) quit;;
    'A' ) apps-menu;;
    'N' ) new-task;;
    'E' ) edit-task;;
    'X' ) close-task;;
    'M' ) more-options;;
  esac
done
