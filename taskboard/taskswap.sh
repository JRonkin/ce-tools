new() {
	repo=$1
	jiranum=$2

	killall -9 grunt

	cd ~/repo
	git clone $repo || true

	printf 'tell app "Terminal"
				do script "cd ~/repo/${repo} && git co -b ${jiranum}/trunk"
			end tell
		' | osascript

	printf 'tell app "Terminal"
				do script "cd ~/repo/${repo}/src; rm yarn.lock; yarn install; bower install; bundle install"
			end tell
		' | osascript
}

activate() {

}

deactivate() {

}

close() {

}