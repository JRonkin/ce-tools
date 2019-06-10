#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common/funcs.sh"

while read appfile
do
	source "$(dirname "${BASH_SOURCE[0]}")/apps/$appfile"
done <<< "$(ls "$(dirname "${BASH_SOURCE[0]}")/apps")"

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

new() {
	local name="$1"
	local jiranum="$2"
	local repo="$3"
	
	local CONFIG_DIR="$(dirname "${BASH_SOURCE[0]}")/../appdata/taskboard"
	local monitors

	local folder="${ITEMS_DIR}${jiranum}"
	[ "$ITEMS_DIR" ] || folder="${HOME}/items/${jiranum}"

	mkdir -p "$folder"

	if [ "$repo" ]
	then
		# Clone repo, suppressing error if repo already exists
		git clone --recurse-submodules -j8 "git@github.com:yext-pages/${repo}.git" "${folder}/${repo}" || true &
	fi

	# Set up new task
	echo -e "name=\"${name}\"\nsymbol='*'" > "${folder}/.taskboard"

	# Load window bounds
	[ -f "${CONFIG_DIR}/windowbounds" ] && source "${CONFIG_DIR}/windowbounds"

	# Count the number of displays (monitors)
	monitors=$(system_profiler SPDisplaysDataType -detaillevel mini | grep -c "Display Serial")

	wait

	for app in "${apps[@]}"
	do
		if [ ${enabledApps[$(hash "$app")]} ]
		then
			new_$(echo "$app" | tr -d ' ') "$jiranum" "$repo" "$monitors" &
		fi
	done
}

activate() {
	local jiranum="$1"
	local repo="$2"

	local folder="${ITEMS_DIR}${jiranum}"
	[ "$ITEMS_DIR" ] || folder="${HOME}/items/${jiranum}"

	sed -i '' "s/^symbol=.*/symbol='*'/" "${folder}/.taskboard"

	for app in "${apps[@]}"
	do
		[ ${enabledApps[$(hash "$app")]} ] && osascript -e "tell app \"${app}\" to set index of every $(selector "$app" "$jiranum" "$repo") to 1" &
	done
}

deactivate() {
	local jiranum="$1"
	local repo="$2"

	local folder="${ITEMS_DIR}${jiranum}"
	[ "$ITEMS_DIR" ] || folder="${HOME}/items/${jiranum}"

	sed -i '' "s/^symbol=.*/symbol=' '/" "${folder}/.taskboard"

	for app in "${apps[@]}"
	do
		if [ ${enabledApps[$(hash "$app")]} ]
		then
			osascript -e "tell app \"${app}\" to set miniaturized of every $(selector "$app" "$jiranum" "$repo") to true" 2>/dev/null &
			osascript -e "tell app \"${app}\" to set minimized of every $(selector "$app" "$jiranum" "$repo") to true" 2>/dev/null &
		fi
	done
}

close() {
	local jiranum="$1"
	local repo="$2"

	local folder="${ITEMS_DIR}${jiranum}"
	[ "$ITEMS_DIR" ] || folder="${HOME}/items/${jiranum}"

	for app in "${apps[@]}"
	do
		[ ${enabledApps[$(hash "$app")]} ] && osascript -e "tell app \"${app}\" to close every $(selector "$app" "$jiranum" "$repo")" &
	done

	wait

	trash "$folder"
}
