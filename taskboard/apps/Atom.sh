selector_Atom() {
	local jiranum="$1"
	local repo="$2"

	echo "window whose name contains \"/${jiranum}/${repo}\""
}

save-window-bounds_Atom() {
	local jiranum="$1"
	local repo="$2"

	echo "bounds_Atom='$(osascript -e "tell app \"Atom\" to get the bounds of the 1st $(selector_Atom "$jiranum" "$repo")")'"
}

new_Atom() {
	local jiranum="$1"
	local repo="$2"
	local monitors="$3"

	if [ "$repo" ]
	then
		local bounds='279, 23, 1610, 1050'
		[ $monitors -gt 1 ] && bounds='1920, 23, 3254, 1123'
		[ "$bounds_Atom" ] && bounds="$bounds_Atom"

		local selector="$(selector_Atom "$jiranum" "$repo")"

		atom "${folder}/${repo}" && sleep 2 &&
			printf "
				tell app \"Atom\"
					set timer to 0
					repeat until the length of (get every ${selector}) > 0 or timer > 15
						delay 0.5
						set timer to timer + 0.5
					end repeat
					set the bounds of every ${selector} to {${bounds}}
				end tell
			" | osascript &
	fi
}

apps[${#apps[*]}]='Atom'