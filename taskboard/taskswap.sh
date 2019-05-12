apps="\
Atom
Google Chrome
Terminal"

enableApp() {
	[ "$1" ] && enabledApps[$(cksum <<< "$1" | cut -d ' ' -f 1)]=true
}

disableApp() {
	[ "$1" ] && enabledApps[$(cksum <<< "$1" | cut -d ' ' -f 1)]=
}

appEnabled() {
	[ "$1" ] && echo ${enabledApps[$(cksum <<< "$1" | cut -d ' ' -f 1)]}
}

selector() {
	local app="$1"
	local jiranum="$2"
	local repo="$3"

	case "$app" in
		"Atom" )
			echo "window whose name contains \"/${jiranum}/${repo}\""
		;;
		"Google Chrome" )
			echo "window where the title of the 1st tab contains \"[${jiranum}]\""
		;;
		"Terminal" )
			echo "window whose name contains \"${jiranum} — \""
		;;
	esac
}

save-window-bounds() {
	local jiranum=$(echo "$1" | cut -d " " -f 1)
	local repo=$(echo "$1" | cut -d " " -f 4)

	local dir="$(dirname "${BASH_SOURCE[0]}")/../appdata/taskboard"
	mkdir -p "$dir"

	(
		echo "atomBounds='$(osascript -e "tell app \"Atom\" to get the bounds of the 1st $(selector 'Atom' "$jiranum" "$repo")")'" &
		echo "chromeBounds='$(osascript -e "tell app \"Google Chrome\" to get the bounds of the 1st $(selector 'Google Chrome' "$jiranum" "$repo")")'" &
		echo "terminal1Bounds='$(osascript -e "tell app \"Terminal\" to get the bounds of the 1st $(selector 'Terminal' "$jiranum" "$repo")")'" &
		echo "terminal2Bounds='$(osascript -e "tell app \"Terminal\" to get the bounds of the 2nd $(selector 'Terminal' "$jiranum" "$repo")")'" &
		wait
	) | sort > "${dir}/windowbounds"
}

new() {
	local name="$1"
	local jiranum="$2"
	local repo="$3"
	local folder="${HOME}/items/${jiranum}"

	if [ "$repo" ]
	then
		# Clone repo, suppressing error if repo already exists
		mkdir -p "$folder" 2>/dev/null
		git clone --recurse-submodules -j8 "git@github.com:yext-pages/${repo}.git" "${folder}/${repo}" || true &
		local clonePID=$!

		# Additional tabs for Chrome
		local chromeCmds="make new tab in new_window
					set the URL of the active tab of new_window to \"https://github.com/yext-pages/${repo}\"
					make new tab in new_window
					set the URL of the active tab of new_window to \"https://www.yext.com/pagesadmin/?query=$(echo "${repo//[Mm]aster[^A-Za-z0-9]}" | tr A-Z a-z)\""
	fi

	# Load window bounds
	local dir="$(dirname "${BASH_SOURCE[0]}")/../appdata/taskboard"
	mkdir -p "$dir"
	touch "${dir}/windowbounds"

	local chromeBounds="279, 23, 1610, 1050"
	local terminal1Bounds="0, 698, 571, 1050"
	local terminal2Bounds="0, 347, 571, 700"
	local atomBounds="279, 23, 1610, 1050"

	# If more than one monitor, use dual monitor window defaults
	if [ $(system_profiler SPDisplaysDataType -detaillevel mini | grep -c "Display Serial") -gt 1 ]
	then
		chromeBounds="232, 23, 1919, 1118"
		terminal1Bounds="3255, 757, 3840, 1123"
		terminal2Bounds="3255, 390, 3840, 756"
		atomBounds="1920, 23, 3254, 1123"
	fi

	source "${dir}/windowbounds"

	# Set up new task
	echo -e "name=${name}\nsymbol='*'" > "${dir}/.taskboard"

	if [ $(appEnabled 'Google Chrome') ]
	then
		printf 'tell app "Google Chrome"
					set new_window to (make new window)
					set the bounds of new_window to {'"$chromeBounds"'}
					set the URL of the 1st tab of new_window to "https://yexttest.atlassian.net/browse/'"$jiranum"'"
					'"$chromeCmds"'
					set the active tab index of new_window to 1
				end tell
			' | osascript &
	fi

	if [ "$repo" ]
	then
		if [ $(appEnabled 'Atom') ]
		then
			atom "${folder}/${repo}" && sleep 2 &&
			printf 'tell app "Atom"
						set timer to 0
						repeat until the length of (get every '"$(selector 'Atom' "$jiranum" "$repo")"') > 0 or timer > 15
							delay 0.5
							set timer to timer + 0.5
						end repeat
						set the bounds of every '"$(selector 'Atom' "$jiranum" "$repo")"' to {'"$atomBounds"'}
					end tell
				' | osascript &
		fi

		# Wait for git clone parallel process to finish
		wait $clonePID

		if [ $(appEnabled 'Terminal') ]
		then
			printf 'tell app "Terminal"
						do script "J='"$jiranum"'; cd '"${folder}/${repo}"'/src && if [ ! -d node_modules ]; then '"$(pwd)"'/../scripts/repo-fixes.sh; yarn install; bower install; bundle install; fi"
						set the custom title of the front window to "'"$jiranum"'"
						set the bounds of the front '"$(selector 'Terminal' "$jiranum" "$repo")"' to {'"$terminal1Bounds"'}

						do script "J='"$jiranum"'; cd '"${folder}/${repo}"' && git co '"$jiranum"'/trunk || (git co master && git co -b '"$jiranum"'/trunk); git branch"
						set the custom title of the front window to "'"$jiranum"'"
						set the bounds of the front '"$(selector 'Terminal' "$jiranum" "$repo")"' to {'"$terminal2Bounds"'}
					end tell
				' | osascript &
		fi
	else
		if [ $(appEnabled 'Terminal') ]
		then
			printf 'tell app "Terminal"
						do script "J='"$jiranum"'"
						set the custom title of the front window to "'"$jiranum"'"
						set the bounds of the front '"$(selector 'Terminal' "$jiranum" "$repo")"' to {'"$terminal2Bounds"'}
					end tell
				' | osascript &
		fi

		# Wait for git clone parallel process to finish
		wait $clonePID
	fi
}

activate() {
	local jiranum=$(echo "$1" | cut -d " " -f 1)
	local repo=$(echo "$1" | cut -d " " -f 4)

	while read app
	do
		[ $(appEnabled "$app") ] && osascript -e "tell app \"${app}\" to set index of every $(selector "$app" "$jiranum" "$repo") to 1" &
	done <<< "$apps"
}

deactivate() {
	local jiranum=$(echo "$1" | cut -d " " -f 1)
	local repo=$(echo "$1" | cut -d " " -f 4)

	while read app
	do
		if [ $(appEnabled "$app") ]
		then
			osascript -e "tell app \"${app}\" to set miniaturized of every $(selector "$app" "$jiranum" "$repo") to true" 2>/dev/null &
			osascript -e "tell app \"${app}\" to set minimized of every $(selector "$app" "$jiranum" "$repo") to true" 2>/dev/null &
		fi
	done <<< "$apps"
}

close() {
	local jiranum=$(echo "$1" | cut -d " " -f 1)
	local repo=$(echo "$1" | cut -d " " -f 4)

	while read app
	do
		[ $(appEnabled "$app") ] && osascript -e "tell app \"${app}\" to close every $(selector "$app" "$jiranum" "$repo")" &
	done <<< "$apps"
}
