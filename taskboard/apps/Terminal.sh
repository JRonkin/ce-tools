selector_Terminal() {
	local jiranum="$1"
	local repo="$2"

	echo "window whose name contains \"${jiranum} — \""
}

save-window-bounds_Terminal() {
	local jiranum="$1"
	local repo="$2"

	echo "bounds_Terminal1='$(osascript -e "tell app \"Terminal\" to get the bounds of the 1st $(selector_Terminal "$jiranum" "$repo")")'" &
	echo "bounds_Terminal2='$(osascript -e "tell app \"Terminal\" to get the bounds of the 2nd $(selector_Terminal "$jiranum" "$repo")")'"

	wait
}

new_Terminal() {
	local jiranum="$1"
	local repo="$2"
	local monitors="$3"

	local bounds1='0, 698, 571, 1050'
	local bounds2='0, 347, 571, 700'
	if [ $monitors -gt 1 ]
	then
		bounds1='3255, 757, 3840, 1123'
		bounds2='3255, 390, 3840, 756'
	fi
	[ "$bounds_Terminal1" ] && bounds1="$bounds_Terminal1"
	[ "$bounds_Terminal2" ] && bounds2="$bounds_Terminal2"

	local selector="$(selector_Terminal "$jiranum" "$repo")"

	if [ "$repo" ]
	then
		printf "
			tell app \"Terminal\"
				do script \"J=${jiranum}; cd ${folder}/${repo}/src && if [ ! -d node_modules ]; then $(pwd)/../scripts/repo-fixes.sh; yarn install; bower install; bundle install; fi\"
				set the custom title of the front window to \"${jiranum}\"
				set the bounds of the front ${selector} to {${bounds1}}

				do script \"J=${jiranum}; cd ${folder}/${repo} && (git co ${jiranum}/trunk || git co master; git branch)\"
				set the custom title of the front window to \"${jiranum}\"
				set the bounds of the front ${selector} to {${bounds2}}
			end tell
		" | osascript &
	else
		printf "
			tell app \"Terminal\"
				do script \"J=${jiranum}\"
				set the custom title of the front window to \"${jiranum}\"
				set the bounds of the front ${selector} to {${bounds2}}
			end tell
		" | osascript &
	fi
}

apps[${#apps[@]}]='Terminal'
