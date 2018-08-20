new() {
	repo=$1
	jiranum=$2

	killall -9 grunt || true

	cd ~/repo
	echo "Cloning git@github.com:yext-pages/${repo}.git"
	git clone "git@github.com:yext-pages/${repo}.git" || true

	printf 'tell app "Terminal"
				do script "cd ~/repo/%s && git co %s/trunk || git co -b %s/trunk"
			end tell
		' $repo $jiranum $jiranum | osascript

	printf 'tell app "Terminal"
				do script "cd ~/repo/%s/src && touch yarn.lock && rm yarn.lock && yarn install && bower install && bundle install"
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