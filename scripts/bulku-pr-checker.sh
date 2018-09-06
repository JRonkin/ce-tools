read -p "Site URL: " siteurl
if [[ "$siteurl" =~ https?:\/\/(.*) ]]
then
	site=${BASH_REMATCH[1]}
else
	printf "Invalid URL:\n$siteurl\n"
	exit
fi

printf 'tell app "Google Chrome"
			make new tab in front window
			set the URL of the active tab of the front window to "https://www.yext.com/pagesadmin/?query=%s"
		end tell
		' "$site" | osascript

read -p "GitHub URL: " giturl
if [[ "$giturl" =~ .*github\.com\/[^/]+\/([^/]+).* ]]
then
	repo=${BASH_REMATCH[1]}
else
	printf "Invalid URL:\n$giturl\n"
	exit
fi

printf 'tell app "Terminal"
			set the custom title of the front window to "%s"
		end tell

		tell app "Google Chrome"
			make new tab in front window
			set the URL of the active tab of the front window to "https://github.com/yext-pages/%s/pulls"
		end tell
		' "$repo" "$repo" | osascript &

cd ~/repo
git clone "git@github.com:yext-pages/${repo}.git" || true
cd "${repo}/src" && if [ ! -d node_modules ]; then rm yarn.lock; yarn install; git co HEAD -- yarn.lock; bower install; bundle install; fi
n $(cat .node-version) 8.11.3
git co PC-35593/trunk && git rebase master && git co PC-35593/doit && git rebase PC-35593/trunk
git build -p && git push origin PC-35593/build

read -p "${repo} Approved and merged on GitHub? (Y/n) " approved
if [ "$approved" = "" -o "$approved" = "y" -o "$approved" = "Y" ]
then
	git co PC-35593/trunk
	git pull
	git push origin :PC-35593/doit
	n $(cat .node-version) 8.11.3
	git finish
	cd ~/repo
	mkdir Trash
	mv $repo Trash/$repo
fi
