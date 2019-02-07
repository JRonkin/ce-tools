die() { echo "$@" >&2; exit 1; }

printf "
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!                                      !
!               HOLD UP!               !
!                                      !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

READ THIS PAGE before doing anything: https://sites.google.com/yext.com/consulting-engineering/pages/deactivating-a-site

Only archive a site if you are ABSOLUTELY sure that you're supposed to be doing it!

Double-check everything!

"

read -p 'Are you SURE you want to deactivate a site? Type the title of the above article to continue: ' confirmation
if [ ! "$(echo "$confirmation" | tr A-Z a-z)" = "deactivating a site" ]
then
	echo "Title does not match. Exiting script."
	exit
fi

echo "Continuing to deactivation..."

echo
echo "The site's repo will be cloned to a new folder in ${HOME}/repo/"
read -p "GitHub URL of site to deactivate: " giturl
if [[ "$giturl" =~ .*github\.com\/[^/]+\/([^/]+).* ]]
then
	repo="${BASH_REMATCH[1]}"
else
	echo "Invalid GitHub URL:\n${giturl}"
	exit 1
fi
git clone "git@github.com:yext-pages/${repo}.git" "${HOME}/repo/${repo}" || die "Cloning repo failed. Exiting script."
(
	cd "${HOME}/repo/${repo}"
	git branch -r | grep -v '\->' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done
	git fetch --all
	git pull --all
) || die "Cloning repo failed. Exiting script."

echo
echo "All branches of repo cloned successfully."

echo "$repo" | pbcopy

echo
echo "This repo name has been copied to your clipboard:"
echo "$repo"
echo "Press Enter to open a new Chrome tab to Stash."
echo 'Paste in the name of the repo, and press "Create repository".'
read -p ""

open -a "Google Chrome" 'https://stash.office.yext.com/projects/PA/repos?create'

echo
echo "Press Enter once the new Stash repo has been created."
read -p ""

(
	cd "${HOME}/repo/${repo}"
	git remote set-url origin "ssh://git@stash.office.yext.com:1234/pa/${repo}.git" &&
	git push --all &&
	git push --tags
) || die "Pushing to Stash failed. Exiting script. Please push manually: git remote set-url origin \"ssh://git@stash.office.yext.com:1234/pa/${repo}.git\" && git push --all && git push --tags"

echo
echo "Source code archive complete. Starting site files download..."
$(dirname "${BASH_SOURCE[0]}")/s3-download.sh || die "Downloading site files failed. Exiting script."
echo "Zipping site files into '${HOME}/repo/${domain}.zip'..."
zip -qrX "${domain}.zip" "${domain}_files"

echo
echo "FINAL STEP: Delete the site"
echo 'Once you are sure that the site has been archived successfully, follow the instructions on this page under "Deleting the Site":'
echo "https://sites.google.com/yext.com/consulting-engineering/pages/deactivating-a-site"
echo
echo "Press Enter to exit script."
read -p ""