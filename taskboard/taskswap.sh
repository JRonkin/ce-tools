BASE_DIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")/..")"
CONFIG_DIR="${BASE_DIR}/appdata/taskboard"
APPS_DIR="${BASE_DIR}/taskboard/apps"
APP_COMMAND_LOG_FILE="${CONFIG_DIR}/taskswap_apps.log"

source "${BASE_DIR}/common/funcs.sh"

while read app
do
  apps[${#apps[@]}]="$app"
done <<< "$(ls "${APPS_DIR}")"

update-current-display() {
  currentDisplay="$(
    system_profiler SPDisplaysDataType |
      awk '/Resolution:/{ printf "%s %s %s\n", $2, $4, ($5 == "Retina" ? 2 : 1) }'
  )"
}

save-window-bounds() {
  local app="$1"
  local jiranum="$2"
  local repo="$3"

  local appBounds="$(app-command 'getbounds' "$app" "$jiranum" "$repo" 2>/dev/null)"

  [ "$appBounds" ] || return 1

  local file="${CONFIG_DIR}/windowBounds"

  update-current-display
  touch "$file"
  echo "windowBounds[$(hash "${currentDisplay}/${app}")]='${appBounds}'
$(cat "$file" | grep -v "windowBounds\[$(hash "${currentDisplay}/${app}")\]=")" >"${file}.tmp"
  mv "${file}.tmp" "$file"
}

app-command() {
  local command="$1"
  local app="$2"
  local jiranum="$3"
  local repo="$4"

  # Load window bounds
  [ -f "${CONFIG_DIR}/windowBounds" ] && source "${CONFIG_DIR}/windowBounds"

  local appBounds="${windowBounds[$(hash "${currentDisplay}/${app}")]}"
  local position="$(echo "$appBounds" | cut -d '|' -f 1)"
  local size="$(echo "$appBounds" | cut -d '|' -f 2)"

  pushd "${APPS_DIR}/${app}" >/dev/null
  JIRA_ORG="$JIRA_ORG" GITHUB_ORG="$GITHUB_ORG" "${APPS_DIR}/${app}/${command}.sh" "${ITEMS_DIR}/${jiranum}" "$jiranum" "$repo" "$position" "$size"
  popd >/dev/null
}

new() {
  local name="$1"
  local jiranum="$2"
  local repo="$3"

  local folder
  if [ "$ITEMS_DIR" ]
  then
    folder="${ITEMS_DIR}/${jiranum}"
  else
    folder="${HOME}/items/${jiranum}"
  fi

  mkdir -p "$folder"

  # Set up new task
  echo -e "name='$(echo "$name" | sed "s/'/'\"'\"'/g")'\nsymbol='*'\nrepo='${repo}'" > "${folder}/.taskboard"

  if [ "$repo" ]
  then
    # Clone repo and submodules
    git clone --recurse-submodules -j8 "git@github.com:${GITHUB_ORG}${repo}.git" "${folder}/${repo}" || true &
  fi

  update-current-display

  # Wait for repo to finish being cloned
  wait

  for app in "${apps[@]}"
  do
    [ ${enabledApps[$(hash "$app")]} ] && app-command 'new' "$app" "$jiranum" "$repo" &
  done
}

activate() {
  local jiranum="$1"
  local repo="$2"

  sed -i '' "s/^symbol=.*/symbol='*'/" "${ITEMS_DIR}/${jiranum}/.taskboard"

  for app in "${apps[@]}"
  do
    [ ${enabledApps[$(hash "$app")]} ] && app-command 'activate' "$app" "$jiranum" "$repo" &
  done
}

deactivate() {
  local jiranum="$1"
  local repo="$2"

  sed -i '' "s/^symbol=.*/symbol=' '/" "${ITEMS_DIR}/${jiranum}/.taskboard"

  for app in "${apps[@]}"
  do
    [ ${enabledApps[$(hash "$app")]} ] && app-command 'deactivate' "$app" "$jiranum" "$repo" &
  done
}

setbounds() {
  local jiranum="$1"
  local repo="$2"

  update-current-display

  for app in "${apps[@]}"
  do
    [ ${enabledApps[$(hash "$app")]} ] && app-command 'setbounds' "$app" "$jiranum" "$repo" 2>/dev/null &
  done
}

close() {
  local jiranum="$1"
  local repo="$2"

  for app in "${apps[@]}"
  do
    [ ${enabledApps[$(hash "$app")]} ] && app-command 'close' "$app" "$jiranum" "$repo" &
  done

  wait

  trash "${ITEMS_DIR}/${jiranum}"
}

update-current-display
