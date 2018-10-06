save-window-bounds() {
	local repo=$(echo "$1" | cut -d " " -f 4)
	local jiranum=$(echo "$1" | cut -d " " -f 1)

	local dir="$(dirname "${BASH_SOURCE[0]}")/../appdata/taskboard"
	mkdir -p "$dir"

	echo "terminal1Bounds=$(printf 'tell app "Terminal" to get the bounds of the 1st window whose custom title is "%s"' "$repo" | osascript)" > "${dir}/windowbounds"
	echo "terminal2Bounds=$(printf 'tell app "Terminal" to get the bounds of the 2nd window whose custom title is "%s"' "$repo" | osascript)" >> "${dir}/windowbounds"
	echo "chromeBounds=$(printf 'tell app "Google Chrome" to get the bounds of the 1st window where the title of the 1st tab contains "[%s]"' "$jiranum" | osascript)" >> "${dir}/windowbounds"
	echo "atomBounds=$(printf 'tell app "Atom" to get the bounds of the 1st window whose name contains "~/repo/%s"' "$repo" | osascript)" >> "${dir}/windowbounds"
}

new() {
	local repo=$1
	local jiranum=$2

	# Load window bounds
	local dir="$(dirname "${BASH_SOURCE[0]}")/../appdata/taskboard"
	mkdir -p "$dir"
	touch "${dir}/windowbounds"

	local terminal1Bounds="0, 698, 571, 1050"
	local terminal2Bounds="0, 347, 571, 700"
	local chromeBounds="268, 23, 1599, 1050"
	local atomBounds="268, 23, 1599, 1050"

	local line
	while read line
	do
		case "$(echo "$line" | cut -d "=" -f 1)" in
			"terminal1Bounds" )
				terminal1Bounds="$(echo "$line" | cut -d "=" -f 2)"
			;;
			"terminal2Bounds" )
				terminal2Bounds="$(echo "$line" | cut -d "=" -f 2)"
			;;
			"chromeBounds" )
				chromeBounds="$(echo "$line" | cut -d "=" -f 2)"
			;;
			"atomBounds" )
				atomBounds="$(echo "$line" | cut -d "=" -f 2)"
			;;
		esac
	done < "$dir/windowbounds"

	# Set up new task
	git clone "git@github.com:yext-pages/${repo}.git" "${HOME}/repo/${repo}" || true

	printf 'tell app "Terminal"
				do script "cd ~/repo/%s/src && if [ ! -d node_modules ]; then %s/../scripts/fix-yarn-modernizr.sh; yarn install; bower install; bundle install; fi"
				set the custom title of the front window to "%s"
				set the bounds of the front window whose custom title is "%s" to {%s}

				do script "cd ~/repo/%s && atom . && git co %s/trunk || (git co master && git co -b %s/trunk); git branch"
				set the custom title of the front window to "%s"
				set the bounds of the front window whose custom title is "%s" to {%s}
			end tell
		' "$repo" "$(pwd)" "$repo" "$repo" "$terminal1Bounds" "$repo" "$jiranum" "$jiranum" "$repo" "$repo" "$terminal2Bounds" | osascript &

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
		' "$chromeBounds" "$jiranum" "$repo" "${repo//[Mm]aster[^A-Za-z0-9]}" | osascript &

	printf 'tell app "Atom"
				set timer to 0
				repeat until the length of (get every window whose name contains "~/repo/%s") > 0 or timer > 20
					delay 0.5
					set timer to timer + 0.5
				end repeat
				set the bounds of every window whose name contains "~/repo/%s" to {%s}
			end tell
		' "$repo" "$repo" "$atomBounds" | osascript &
}

activate() {
	local repo=$(echo "$1" | cut -d " " -f 4)
	local jiranum=$(echo "$1" | cut -d " " -f 1)

	printf 'tell app "Terminal"
				set index of every window whose custom title is "%s" to 1
			end tell
		' "$repo" | osascript &

	printf 'tell app "Google Chrome"
				set index of every window where the title of the 1st tab contains "[%s]" to 1
			end tell
		' "$jiranum" | osascript &

	printf 'tell app "Atom"
				set index of every window whose name contains "~/repo/%s" to 1
			end tell
		' "$repo" | osascript &
}

deactivate() {
	local repo=$(echo "$1" | cut -d " " -f 4)
	local jiranum=$(echo "$1" | cut -d " " -f 1)

	printf 'tell app "Terminal"
				set miniaturized of every window whose custom title is "%s" to true
			end tell
		' "$repo" | osascript &

	printf 'tell app "Google Chrome"
				set minimized of every window where the title of the 1st tab contains "[%s]" to true
			end tell
		' "$jiranum" | osascript &

	printf 'tell app "Atom"
				set miniaturized of every window whose name contains "~/repo/%s" to true
			end tell
		' "$repo" | osascript &
}

close() {
	local repo=$(echo "$1" | cut -d " " -f 4)
	local jiranum=$(echo "$1" | cut -d " " -f 1)

	printf 'tell app "Terminal"
				close every window whose custom title is "%s"
			end tell
		' "$repo" | osascript &

	printf 'tell app "Google Chrome"
				close every window where the title of the 1st tab contains "[%s]"
			end tell
		' "$jiranum" | osascript &

	printf 'tell app "Atom"
				close every window whose name contains "~/repo/%s"
			end tell
		' "$repo" | osascript &
}