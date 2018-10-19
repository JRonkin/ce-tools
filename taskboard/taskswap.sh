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

new() {
	local jiranum="$1"
	local repo="$2"

	if [ "$repo" ]
	then
		# Clone repo, suppressing error if repo already exists
		git clone "git@github.com:yext-pages/${repo}.git" "${HOME}/repo/${repo}" || true &
	fi

	# Load window bounds
	local dir="$(dirname "${BASH_SOURCE[0]}")/../appdata/taskboard"
	mkdir -p "$dir"
	touch "${dir}/windowbounds"

	local chromeBounds="268, 23, 1599, 1050"
	local terminal1Bounds="0, 698, 571, 1050"
	local terminal2Bounds="0, 347, 571, 700"
	local atomBounds="268, 23, 1599, 1050"

	# If more than one monitor, use dual monitor window defaults
	if [ $(system_profiler SPDisplaysDataType -detaillevel mini | grep -c "Display Serial") -gt 1 ]
	then
		chromeBounds="189, 23, 1919, 1118"
		terminal1Bounds="3255, 757, 3840, 1123"
		terminal2Bounds="3255, 390, 3840, 756"
		atomBounds="1920, 23, 3254, 1123"
	fi

	touch "$dir/windowbounds"
	source "$dir/windowbounds"

	# Wait for git clone parallel process to finish
	wait

	# Set up new task
	if [ "$enableChrome" ]
	then
		printf 'tell app "Google Chrome"
					make new window
					set the bounds of the front window to {%s}
					set the URL of the active tab of the front window to "https://yexttest.atlassian.net/browse/%s"
					make new tab in the front window
					set the URL of the active tab of the front window to "https://github.com/yext-pages/%s"
					make new tab in the front window
					set the URL of the active tab of the front window to "https://www.yext.com/pagesadmin/?query=%s"
					set the active tab index of the front window to 1
				end tell
			' "$chromeBounds" "$jiranum" "$repo" "$(echo "${repo//[Mm]aster[^A-Za-z0-9]}" | tr A-Z a-z)" | osascript &
	fi

	if [ "$repo" ]
	then
		if [ "$enableTerminal" ]
		then
			printf 'tell app "Terminal"
						do script "cd ~/repo/%s/src && if [ ! -d node_modules ]; then %s/../scripts/fix-yarn-modernizr.sh; yarn install; bower install; bundle install; fi"
						set the custom title of the front window to "%s"
						set the bounds of the front window whose custom title is "%s" to {%s}

						do script "cd ~/repo/%s && git co %s/trunk || (git co master && git co -b %s/trunk); git branch"
						set the custom title of the front window to "%s"
						set the bounds of the front window whose custom title is "%s" to {%s}
					end tell
				' "$repo" "$(pwd)" "$repo" "$repo" "$terminal1Bounds" "$repo" "$jiranum" "$jiranum" "$repo" "$repo" "$terminal2Bounds" | osascript &
		fi

		if [ "$enableAtom" ]
		then
			atom "$HOME/repo/${repo}" &&
			printf 'tell app "Atom"
						set timer to 0
						repeat until the length of (get every window whose name contains "~/repo/%s") > 0 or timer > 20
							delay 0.5
							set timer to timer + 0.5
						end repeat
						set the bounds of every window whose name contains "~/repo/%s" to {%s}
					end tell
				' "$repo" "$repo" "$atomBounds" | osascript &
		fi
	fi
}

activate() {
	local jiranum=$(echo "$1" | cut -d " " -f 1)
	local repo=$(echo "$1" | cut -d " " -f 4)

	if [ "$enableChrome" ]
	then
		printf 'tell app "Google Chrome"
					set index of every window where the title of the 1st tab contains "[%s]" to 1
				end tell
			' "$jiranum" | osascript &
	fi

	if [ "$repo" ]
	then
		if [ "$enableTerminal" ]
		then
			printf 'tell app "Terminal"
						set index of every window whose name contains " — %s — " to 1
					end tell
				' "$repo" | osascript &
		fi

		if [ "$enableAtom" ]
		then
			printf 'tell app "Atom"
						set index of every window whose name contains "~/repo/%s" to 1
					end tell
				' "$repo" | osascript &
		fi
	fi
}

deactivate() {
	local jiranum=$(echo "$1" | cut -d " " -f 1)
	local repo=$(echo "$1" | cut -d " " -f 4)

	if [ "$enableChrome" ]
	then
		printf 'tell app "Google Chrome"
					set minimized of every window where the title of the 1st tab contains "[%s]" to true
				end tell
			' "$jiranum" | osascript &
	fi

	if [ "$repo" ]
	then
		if [ "$enableTerminal" ]
		then
			printf 'tell app "Terminal"
						set miniaturized of every window whose name contains " — %s — " to true
					end tell
				' "$repo" | osascript &
		fi

		if [ "$enableAtom" ]
		then
			printf 'tell app "Atom"
						set miniaturized of every window whose name contains "~/repo/%s" to true
					end tell
				' "$repo" | osascript &
		fi
	fi
}

close() {
	local jiranum=$(echo "$1" | cut -d " " -f 1)
	local repo=$(echo "$1" | cut -d " " -f 4)

	if [ "$enableChrome" ]
	then
		printf 'tell app "Google Chrome"
					close every window where the title of the 1st tab contains "[%s]"
				end tell
			' "$jiranum" | osascript &
	fi

	if [ "$repo" ]
	then
		if [ "$enableTerminal" ]
		then
			printf 'tell app "Terminal"
						close every window whose name contains " — %s — "
					end tell
				' "$repo" | osascript &
		fi

		if [ "$enableAtom" ]
		then
			printf 'tell app "Atom"
						close every window whose name contains "~/repo/%s"
					end tell
				' "$repo" | osascript &
		fi
	fi
}