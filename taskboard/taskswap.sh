source "$(dirname "${BASH_SOURCE[0]}")/../common/funcs.sh"

while read appfile
do
	source "$(dirname "${BASH_SOURCE[0]}")/apps/$appfile"
done <<< "$(ls "$(dirname "${BASH_SOURCE[0]}")/apps")"

# Count the number of displays (monitors)
monitors=$(system_profiler SPDisplaysDataType -detaillevel mini | grep -c "Display Serial")

selector() {
	local app="$1"
	local jiranum="$2"
	local repo="$3"

	selector_$(echo "$app" | tr -d ' ') "$jiranum" "$repo"
}

save-window-bounds() {
	local jiranum="$1"
	local repo="$2"

	(
		for app in "${apps[@]}"
		do
			if [ ${enabledApps[$(hash "$app")]} ]
			then
				save-window-bounds_$(echo "$app" | tr -d ' ') "$jiranum" "$repo" &
			fi
		done
		wait
	) | sort > "$(dirname "${BASH_SOURCE[0]}")/../appdata/taskboard/windowbounds"
}

new-app() {
	local app="$1"
	local jiranum="$2"
	local repo="$3"

	new_$(echo "$app" | tr -d ' ') "$jiranum" "$repo" "$monitors"
}

new() {
	local name="$1"
	local jiranum="$2"
	local repo="$3"
	
	local CONFIG_DIR="$(dirname "${BASH_SOURCE[0]}")/../appdata/taskboard"

	local folder
	if [ "$ITEMS_DIR" ]
	then
		folder="${ITEMS_DIR}/${jiranum}"
	else
		folder="${HOME}/items/${jiranum}"
	fi

	mkdir -p "$folder"

	# Load window bounds
	[ -f "${CONFIG_DIR}/windowbounds" ] && source "${CONFIG_DIR}/windowbounds"

	# Set up new task
	echo -e "name=\"${name}\"\nsymbol='*'\nrepo='${repo}'" > "${folder}/.taskboard"

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
