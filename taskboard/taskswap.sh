new() {
	repo=$1
	jiranum=$2

	cd ~/repo
	git clone "git@github.com:yext-pages/${repo}.git" || true

	printf 'tell app "Terminal"
				do script "cd ~/repo/%s && atom . && git co %s/trunk || git co -b %s/trunk"
				set the custom title of the front window to %s
				set the bounds of the front window to {3256, 387, 3841, 753}
			end tell
		' "$repo" "$jiranum" "$jiranum" "$repo" | osascript

	printf 'tell app "Terminal"
				do script "cd ~/repo/%s/src && touch yarn.lock && rm yarn.lock && yarn install && bower install && bundle install"
				set the custom title of the front window to %s
				set the bounds of the front window to {3255, 754, 3840, 1120}
			end tell
		' "$repo" "$repo" | osascript
}

activate() {
	repo=$1

	printf 'tell app "Terminal"
				set miniaturized of every window with custom title "%s" to false
			end tell
		' "$repo" | osascript
}

deactivate() {
	repo=$1

	printf 'tell app "Terminal"
				set miniaturized of every window with custom title "%s" to true
			end tell
		' "$repo" | osascript
}

close() {
	repo=$1

	printf 'tell app "Terminal"
				close every window with custom title "%s"
			end tell
		' "$repo" | osascript
}