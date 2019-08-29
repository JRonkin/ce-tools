source "$(dirname "${BASH_SOURCE[0]}")/../common/funcs.sh"

CONFIG_DIR="$(dirname "${BASH_SOURCE[0]}")/../appdata/taskboard"

while read app
do
  apps[${#apps[@]}]="$app"
  selectors[$(hash "$app")]="$(cat "$(dirname "${BASH_SOURCE[0]}")/apps/${app}/selector.txt")"
done <<< "$(ls "$(dirname "${BASH_SOURCE[0]}")/apps")"

selector() {
  local app="$1"
  local jiranum="$2"
  local repo="$3"

  printf "${selectors[$(hash "$app")]}" "$jiranum"
}

save-window-bounds() {
  local app="$1"
  local jiranum="$2"
  local repo="$3"

  local bounds="$(osascript -e "tell app \"${app}\" to get the bounds of the 1st $(selector "$app" "$jiranum" "$repo")" 2>/dev/null)"

  if [ ! "$bounds" ]
  then
    return 1
  fi

  local file="${CONFIG_DIR}/windowbounds"

  touch "$file"
  echo "\
windowBounds[$(hash "$app")]='${bounds}'
$(cat "$file" | grep -v "windowBounds\[$(hash "$app")\]=")" >"${file}.tmp"

  mv "${file}.tmp" "$file"
}

new-app() {
  local app="$1"
  local jiranum="$2"
  local repo="$3"

  # Load window bounds
  [ -f "${CONFIG_DIR}/windowbounds" ] && source "${CONFIG_DIR}/windowbounds"

  "$(dirname "${BASH_SOURCE[0]}")/apps/${app}/new.sh" "${ITEMS_DIR}/${jiranum}" "$jiranum" "$repo" "${windowBounds[$(hash "$app")]}"
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
    git clone --recurse-submodules -j8 "git@github.com:yext-pages/${repo}.git" "${folder}/${repo}" || true
  fi

  for app in "${apps[@]}"
  do
    [ ${enabledApps[$(hash "$app")]} ] && new-app "$app" "$jiranum" "$repo" &
  done
}

activate-app() {
  local app="$1"
  local jiranum="$2"
  local repo="$3"

  osascript -e "tell app \"${app}\" to set index of every $(selector "$app" "$jiranum" "$repo") to 1"
}

activate() {
  local jiranum="$1"
  local repo="$2"

  local folder="${ITEMS_DIR}/${jiranum}"
  [ "$ITEMS_DIR" ] || folder="${HOME}/items/${jiranum}"

  sed -i '' "s/^symbol=.*/symbol='*'/" "${folder}/.taskboard"

  for app in "${apps[@]}"
  do
    [ ${enabledApps[$(hash "$app")]} ] && activate-app "$app" "$jiranum" "$repo" &
  done
}

deactivate-app() {
  local app="$1"
  local jiranum="$2"
  local repo="$3"

  osascript -e "tell app \"${app}\" to set miniaturized of every $(selector "$app" "$jiranum" "$repo") to true" 2>/dev/null
  osascript -e "tell app \"${app}\" to set minimized of every $(selector "$app" "$jiranum" "$repo") to true" 2>/dev/null
}

deactivate() {
  local jiranum="$1"
  local repo="$2"

  local folder="${ITEMS_DIR}/${jiranum}"
  [ "$ITEMS_DIR" ] || folder="${HOME}/items/${jiranum}"

  sed -i '' "s/^symbol=.*/symbol=' '/" "${folder}/.taskboard"

  for app in "${apps[@]}"
  do
    [ ${enabledApps[$(hash "$app")]} ] && deactivate-app "$app" "$jiranum" "$repo" &
  done
}

close-app() {
  local app="$1"
  local jiranum="$2"
  local repo="$3"

  osascript -e "tell app \"${app}\" to close every $(selector "$app" "$jiranum" "$repo")"
}

close() {
  local jiranum="$1"
  local repo="$2"

  local folder="${ITEMS_DIR}/${jiranum}"
  [ "$ITEMS_DIR" ] || folder="${HOME}/items/${jiranum}"

  for app in "${apps[@]}"
  do
    [ ${enabledApps[$(hash "$app")]} ] && close-app "$app" "$jiranum" "$repo" &
  done

  wait

  trash "$folder"
}
