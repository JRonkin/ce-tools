new() {
	repo=$1
	jiranum=$2

	cd ~/repo
	git clone "git@github.com:yext-pages/${repo}.git" || true

	printf 'tell app "Terminal"
				do script "cd ~/repo/%s/src && if [ ! -d node_modules ]; then touch yarn.lock && rm yarn.lock && yarn install && bower install && bundle install; fi"
				set the custom title of the front window to "%s"
				set the bounds of the front window to {3255, 754, 3840, 1120}

				do script "cd ~/repo/%s && atom . && git co %s/trunk || git co -b %s/trunk; git branch"
				set the custom title of the front window to "%s"
				set the bounds of the front window to {3256, 387, 3841, 753}
			end tell
		' "$repo" "$repo" "$repo" "$jiranum" "$jiranum" "$repo" | osascript &

	printf 'tell app "Google Chrome"
				make new window
				set the bounds of the front window to {189, 23, 1919, 1118}
				set the URL of the active tab of the front window to "https://yexttest.atlassian.net/browse/%s"
				make new tab in the front window
				set the URL of the active tab of the front window to "https://github.com/yext-pages/%s"
				make new tab in the front window
				set the URL of the active tab of the front window to "https://www.yext.com/pagesadmin/?query=%s"
				set the active tab index of the front window to 1
			end tell
		' "$jiranum" "$repo" "$repo" | osascript &
}

activate() {
	repo=$(echo "$1" | cut -d " " -f 4)
	jiranum=$(echo "$1" | cut -d " " -f 1)

	printf 'tell app "Terminal"
				set index of every window whose name contains " — %s — -bash" to 1
			end tell
		' "$repo" | osascript &

	printf 'tell app "Atom"
				set index of every window whose name contains "~/repo/%s" to 1
			end tell
		' "$repo" | osascript &

	printf 'tell app "Google Chrome"
				set index of every window where the title of the 1st tab contains "[%s]" to 1
			end tell
		' "$jiranum" | osascript &
}

deactivate() {
	repo=$(echo "$1" | cut -d " " -f 4)
	jiranum=$(echo "$1" | cut -d " " -f 1)

	printf 'tell app "Terminal"
				set miniaturized of every window whose name contains " — %s — -bash" to true
			end tell
		' "$repo" | osascript &

	printf 'tell app "Atom"
				set miniaturized of every window whose name contains "~/repo/%s" to true
			end tell
		' "$repo" | osascript &

	printf 'tell app "Google Chrome"
				set minimized of every window where the title of the 1st tab contains "[%s]" to true
			end tell
		' "$jiranum" | osascript &
}

close() {
	repo=$(echo "$1" | cut -d " " -f 4)
	jiranum=$(echo "$1" | cut -d " " -f 1)

	printf 'tell app "Terminal"
				close every window whose name contains " — %s — -bash"
			end tell
		' "$repo" | osascript &

	printf 'tell app "Atom"
				close every window whose name contains "~/repo/%s"
			end tell
		' "$repo" | osascript &

	printf 'tell app "Google Chrome"
				close every window where the title of the 1st tab contains "[%s]"
			end tell
		' "$jiranum" | osascript &
}