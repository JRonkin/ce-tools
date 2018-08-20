new() {
	repo=$1
	jiranum=$2

	cd ~/repo
	git clone "git@github.com:yext-pages/${repo}.git" || true

	printf 'tell app "Terminal"
				do script "cd ~/repo/%s && atom . && git co %s/trunk || git co -b %s/trunk"
				set the bounds of the front window to {3256, 387, 3841, 753}
			end tell
		' $repo $jiranum $jiranum | osascript

	printf 'tell app "Terminal"
				do script "cd ~/repo/%s/src && touch yarn.lock && rm yarn.lock && yarn install && bower install && bundle install"
				set the bounds of the front window to {3255, 754, 3840, 1120}
			end tell
		' $repo | osascript
}

activate() {
	repo=$1
}

deactivate() {
	repo=$1
}

close() {
	repo=$1
}