# Helper Functions

save-config() {
  echo "\
GITHUB_ORG='${GITHUB_ORG}'
ITEMS_DIR='${ITEMS_DIR}'
JIRA_ORG='${JIRA_ORG}'
" > ../appdata/taskboard/taskswap.config

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

read-jira() {
  local jiraUrl="$1"
  local jiranum

  [ ! "$jiraUrl" ] && read -p 'JIRA URL or Number: ' jiraUrl

  if [[ "$jiraUrl" =~ .*\.atlassian\.net\/browse\/([^/#?]+).* ]]
  then
    jiranum="${BASH_REMATCH[1]}"
  else
    jiranum="$jiraUrl"
  fi

  if [[ "$jiranum" =~ ^[A-Za-z]+-[0-9]+$ ]]
  then
    echo "$jiranum"
  fi
}

read-repo() {
  local gitUrl="$1"
  local repo

  [ ! "$gitUrl" ] && read -p 'GitHub URL or Repo Name (blank for none): ' gitUrl

  repo="$gitUrl"
  if [[ "$gitUrl" =~ .*github\.com\/[^/]+\/([^/]+).* ]]
  then
    repo="${BASH_REMATCH[1]}"
  fi

  echo "$repo"
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
  ../scripts/ttitle.sh ''

  exit
}

apps-menu() {
  local appsList="$(
    for app in "${apps[@]}"
    do
      [ ${enabledApps[$(hash "$app")]} ] && echo "$app"
    done
  )"

  local appsOptions="$(timelog-message "$jiranum" "$repo" "$name")
Q: Return to TaskBoard
E: Enable/Disable Apps           | R: Reset Window Positions"

  local appsKeys='Q E R'

  if [ "$appsList" ]
  then
    appsOptions="${appsOptions}
[Enter]: Open App | X: Close App | S: Save Window Position"

    appsKeys="${appsKeys} S X"
  fi

  menu "$appsOptions" "$appsList" 0 $appsKeys

  case "$menu_key" in
    # Open App
    '' ) [ "$menu_value" ] && app-command 'new' "$menu_value" "$jiranum" "$repo" &;;

    # Return to TaskBoard
    'Q' ) ;;

    # Enable/Disable Apps
    'E' )
      if [ "$(osascript -e 'tell app "System Events" to get UI elements enabled')" = 'true' ]
      then
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
      else
        menu 'To let TaskBoard manage app windows, Terminal needs
access to accessibility features. Open Accessibility
settings and check the box next to Terminal to contine.' 'Open Accessibility Settings
Cancel'
        if [ "$menu_selected" -eq 0 ]
        then
          open 'x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility'
        fi
      fi
    ;;

    # Reset App Windows to Their Defaults
    'R' ) setbounds "$jiranum" "$repo" ;;

    # Set Current Window Positions as Default
    'S' )
      if [ "$active_jira" ]
      then
        clear
        if save-window-bounds "$menu_value" "$active_jira" "$active_repo"
        then
          printf "The current window position and size for ${menu_value} has been set as default.\n\n"
        else
          printf "Error: Could not get window position of ${menu_value}. Is there an open window?\n\n"
        fi
        read -p '> Return to TaskBoard'
      else
        clear
        printf "You must have an active task to save window positions.\n\n"
        read -p '> Return to TaskBoard'
      fi
    ;;

    # Close App
    'X' ) app-command 'close' "$menu_value" "$jiranum" "$repo";;
  esac
}

new-task() {
  local jiranum
  local name
  local gitUrl
  local repo

  clear
  tput cnorm
  stty echo

  jiranum="$(read-jira)"
  if [ ! "$jiranum" ]
  then
    tput civis
    stty -echo
    printf "Invalid URL or JIRA Number\n\n> Return to TaskBoard"
    read -sp ''
    return
  fi

  IFS= read -p 'Name: ' name

  repo="$(read-repo)"

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
      sed -i '' "/^name=/d" "${ITEMS_DIR}/${jiranum}/.taskboard"
      echo "name='$(echo "$name" | sed "s/'/'\"'\"'/g")'" >> "${ITEMS_DIR}/${jiranum}/.taskboard"

      if [ "$active_jira" = "$jiranum" ]
      then
        ../timelog/timelog.sh "$(timelog-message "$active_jira" "$active_repo" "$active_name")" end
        active_name="$name"
        ../timelog/timelog.sh "$(timelog-message "$active_jira" "$active_repo" "$active_name")" start
      fi
    ;;
    'R' )
      while :
      do
        source "${ITEMS_DIR}/${jiranum}/.taskboard"
        menu '[Enter]: Select Repo | N: New Repo | X: Remove Repo' "$(list-repos "${ITEMS_DIR}/${jiranum}" "$repo")" 0 'N' 'X'
        case "$menu_key" in
          '' )
            sed -i '' "/^repo=/d" "${ITEMS_DIR}/${jiranum}/.taskboard"
            echo "repo='${menu_value:1}'" >> "${ITEMS_DIR}/${jiranum}/.taskboard"
            break
          ;;
          'N' )
            clear
            tput cnorm
            stty echo

            repo="$(read-repo)"
            [ "$active_jira" = "$jiranum" ] && active_repo="$repo"

            git clone --recurse-submodules -j8 "git@github.com:${GITHUB_ORG}${repo}.git" "${ITEMS_DIR}/${jiranum}/${repo}"
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
I: Change Items Directory
T: TimeReport" ' Return to TaskBoard' 0 'I' 'T'

  case "$menu_key" in
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

    # TimeReport
    'T' )
      clear
      tput cnorm
      stty echo

      read -p 'Start Date (format yyyy-mm-dd; leave blank for today): ' date
      read -p 'End Date (format yyyy-mm-dd; leave blank for same as start): ' endDate

      [ "$active_jira" ] && ../timelog/timelog.sh "$(timelog-message "$active_jira" "$active_repo" "$active_name")" end

      ../timelog/timereport.sh "$date" "$endDate"

      [ "$active_jira" ] && ../timelog/timelog.sh "$(timelog-message "$active_jira" "$active_repo" "$active_name")" start

      tput civis
      stty -echo

      printf "\n\n> Return to TaskBoard"
      read -p ''
    ;;
  esac
}


# PROGRAM START

cd "$(dirname "${BASH_SOURCE[0]}")"

# Set window title
../scripts/ttitle.sh 'TaskBoard'

# Set up directory and files
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
  echo 'Enter the full name of the directory or leave blank to use default:'

  read ITEMS_DIR
  [ "$ITEMS_DIR" ] || ITEMS_DIR="${HOME}/items"
  ITEMS_DIR=${ITEMS_DIR%/}

  save-config
fi
mkdir -p "$ITEMS_DIR"

while [ ! "${JIRA_ORG}" ]
do
  clear
  echo 'Enter your JIRA organization (XXX in https://XXX.atlassian.net):'

  read JIRA_ORG

  save-config
done

if [ ! "${GITHUB_ORG+x}" ]
then
  clear
  echo 'Enter the name of the GitHub organization to use or leave blank for none:'

  read GITHUB_ORG
  [ "$GITHUB_ORG" ] && GITHUB_ORG="${GITHUB_ORG%/}/"

  save-config
fi

# Check for fetched updates
if [ "$(git rev-parse --abbrev-ref HEAD)" = 'master' ] && [ "$(git rev-list 'HEAD..origin/master')" ]
then
  echo 'There are updates available. Would you like to update now?'
  read -p '(Y/n): ' answer
  answer="$(tr 'A-Z' 'a-z' <<< "$answer")"

  if ! [ "$answer" = 'n' ] && ! [ "$answer" = 'no' ]
  then
    git pull && git submodule update --init --recursive
    echo 'Update complete! Please start TaskBoard again.'
    exit
  fi
fi

# Fetch updates in the background
git fetch origin master &> /dev/null &

# Menu loop
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
