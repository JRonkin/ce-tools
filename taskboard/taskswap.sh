save-window-bounds() {
	local jiranum=$(echo "$1" | cut -d " " -f 1)
	local repo=$(echo "$1" | cut -d " " -f 4)

	local dir="$(dirname "${BASH_SOURCE[0]}")/../appdata/taskboard"
	mkdir -p "$dir"

	(
		echo "atomBounds='$(osascript -e "tell app \"Atom\" to get the bounds of the 1st window whose name contains \"~/repo/${repo}\"")'" &
		echo "chromeBounds='$(osascript -e "tell app \"Google Chrome\" to get the bounds of the 1st window where the title of the 1st tab contains \"[${jiranum}]\"")'" &
		echo "terminal1Bounds='$(osascript -e "tell app \"Terminal\" to get the bounds of the 1st window whose name contains \"${repo}\"")'" &
		echo "terminal2Bounds='$(osascript -e "tell app \"Terminal\" to get the bounds of the 2nd window whose name contains \"${repo}\"")'" &
		wait
	) | sort > "${dir}/windowbounds"
}

selector() {
	local app="$1"
	local jiranum="$2"
	local repo="$3"

	case "$app" in
		"Atom" )
			echo 'every window whose name contains "~/repo/'"$repo"'"'
		;;
		"Google Chrome" )
			echo 'every window where the title of the 1st tab contains "['"$jiranum"']"'
		;;
		"Terminal" )
			echo 'every window whose name contains "'"$jiranum"' — "'
		;;
	esac
}

new() {
	local jiranum="$1"
	local repo="$2"

	if [ "$repo" ]
	then
		# Clone repo, suppressing error if repo already exists
		mkdir -p "${HOME}/repo/${repo}" 2>/dev/null
		git clone "git@github.com:yext-pages/${repo}.git" "${HOME}/repo/${repo}" || true &
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
	if [ "$enableChrome" ]
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
		if [ "$enableAtom" ]
		then
			atom "${HOME}/repo/${repo}" && sleep 2 &&
			printf 'tell app "Atom"
						set timer to 0
						repeat until the length of (get every window whose name contains "~/repo/'"$repo"'") > 0 or timer > 15
							delay 0.5
							set timer to timer + 0.5
						end repeat
						set the bounds of every window whose name contains "~/repo/'"$repo"'" to {'"$atomBounds"'}
					end tell
				' | osascript &
		fi

		# Wait for git clone parallel process to finish
		wait $clonePID

		if [ "$enableTerminal" ]
		then
			printf 'tell app "Terminal"
						do script "J='"$jiranum"'; cd ~/repo/'"$repo"'/src && if [ ! -d node_modules ]; then '"$(pwd)"'/../scripts/repo-fixes.sh; yarn install; bower install; bundle install; fi"
						set the custom title of the front window to "'"$jiranum"'"
						set the bounds of the front window whose name contains "'"$jiranum"' — " to {'"$terminal1Bounds"'}

						do script "J='"$jiranum"'; cd ~/repo/'"$repo"' && git co '"$jiranum"'/trunk || (git co master && git co -b '"$jiranum"'/trunk); git branch"
						set the custom title of the front window to "'"$jiranum"'"
						set the bounds of the front window whose name contains "'"$jiranum"' — " to {'"$terminal2Bounds"'}
					end tell
				' | osascript &
		fi
	else
		if [ "$enableTerminal" ]
		then
			printf 'tell app "Terminal"
						do script "J='"$jiranum"'"
						set the custom title of the front window to "'"$jiranum"'"
						set the bounds of the front window whose name contains "'"$jiranum"' — " to {'"$terminal2Bounds"'}
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

	if [ "$enableChrome" ]
	then
		printf 'tell app "Google Chrome"
					set index of every window where the title of the 1st tab contains "['"$jiranum"']" to 1
				end tell
			' | osascript &
	fi

	if [ "$enableTerminal" ]
	then
		printf 'tell app "Terminal"
					set index of every window whose name contains "'"$jiranum"' — " to 1
				end tell
			' | osascript &
	fi

	if [ "$repo" ]
	then
		if [ "$enableAtom" ]
		then
			printf 'tell app "Atom"
						set index of every window whose name contains "~/repo/'"$repo"'" to 1
					end tell
				' | osascript &
		fi
	fi
}

deactivate() {
	local jiranum=$(echo "$1" | cut -d " " -f 1)
	local repo=$(echo "$1" | cut -d " " -f 4)

	if [ "$enableChrome" ]
	then
		printf 'tell app "Google Chrome"
					set minimized of every window where the title of the 1st tab contains "['"$jiranum"']" to true
				end tell
			' | osascript &
	fi

	if [ "$enableTerminal" ]
	then
		printf 'tell app "Terminal"
					set miniaturized of every window whose name contains "'"$jiranum"' — " to true
				end tell
			' | osascript &
	fi

	if [ "$repo" ]
	then
		if [ "$enableAtom" ]
		then
			printf 'tell app "Atom"
						set miniaturized of every window whose name contains "~/repo/'"$repo"'" to true
					end tell
				' | osascript &
		fi
	fi
}

close() {
	local jiranum=$(echo "$1" | cut -d " " -f 1)
	local repo=$(echo "$1" | cut -d " " -f 4)

	if [ "$enableChrome" ]
	then
		printf 'tell app "Google Chrome"
					close every window where the title of the 1st tab contains "['"$jiranum"']"
				end tell
			' | osascript &
	fi

	if [ "$enableTerminal" ]
	then
		printf 'tell app "Terminal"
					close every window whose name contains "'"$jiranum"' — "
				end tell
			' | osascript &
	fi

	if [ "$repo" ]
	then
		if [ "$enableAtom" ]
		then
			printf 'tell app "Atom"
						close every window whose name contains "~/repo/'"$repo"'"
					end tell
				' | osascript &
		fi
	fi
}