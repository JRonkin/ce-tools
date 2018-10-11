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

read -p 'Are you SURE you want to deactivate a site? Type the title of the above web page to continue: ' confirmation
if [ ! "$(echo "$confirmation" | tr A-Z a-z)" = "deactivating a site" ]
then
	echo "Title does not match. Exiting script."
	exit
fi

echo "Continuing to deactivation..."

echo ""
echo "The site's repo will be cloned to a new folder in ${HOME}/repo/"
read -p "GitHub URL of site to deactivate: " giturl
if [[ "$giturl" =~ .*github\.com\/[^/]+\/([^/]+).* ]]
then
	repo="${BASH_REMATCH[1]}"
else
	echo "Invalid GitHub URL:\n${giturl}"
	exit 1
fi
git clone "git@github.com:yext-pages/${repo}.git" "${HOME}/repo/${repo}" || (echo "Cloning repo failed. Exiting script."; exit 1)
(
	cd "${HOME}/repo/${repo}"
	git branch -r | grep -v '\->' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done
	git fetch --all
	git pull --all
) || (echo "Cloning repo failed. Exiting script."; exit 1)

echo ""
echo "All branches of repo cloned successfully."

echo ""
echo "Copy this repo name:"
echo "$repo"
echo ""
echo "Then press Enter to continue."
read -p ""

echo ""
echo "Press Enter to open a new Chrome tab to Stash."
echo 'Paste in the name of the repo, and press "Create repository".'
read -p ""

open -a "Google Chrome" https://stash.office.yext.com/projects/PA/repos?create

echo ""
echo "Press Enter once the new Stash repo has been created."
read -p ""

(
	git remote set-url origin "https://stash.office.yext.com/scm/pa/${repo}.git" &&
	git push --all &&
	git push --tags
) || (echo "Pushing to Stash failed. Please push manually. Exiting script."; exit 1)

echo ""
echo "Source code archive complete. Starting site files archive..."
echo ""
echo "Visit this page if you have not set up AWSCLI:"
echo "https://sites.google.com/yext.com/consulting-engineering/engineering/3-10-aws/aws-cli-setup"
echo ""
echo "Once AWSCLI is set up, press Enter."
read -p ""

echo ""
echo "Getting temporary AWS credentials..."
awscli sts get-caller-identity || (echo "Failed to get AWS credentials. Exiting script."; exit 1)

git clone "ssh://git@stash.office.yext.com:1234/con/freezeray.git" "${HOME}/repo/freezeray" || (echo "Cloning freezeray failed. Exiting script."; exit 1)
(cd "${HOME}/repo/freezeray/cloner" && npm install) || (echo "Failed to install node modules to cloner. Exiting script."; exit 1)
mkdir files

echo ""
read -p "Is the site adaptive? (Y/n)" adaptive
if [ $(echo "$adaptive" | tr A-Z a-z) = "y" ] || [ $(echo "$adaptive" | tr A-Z a-z) = "yes" ]
then
	echo "Site IS adaptive."
	sed -i "" 's/PREFIX = domain \+ "\/prod\/desktop\/"PREFIX = domain \+ "\/prod\//' < index.coffee
else
	echo "Site is NOT adaptive."
fi

echo ""
echo "Cloning site files..."
$(npm bin)/coffee index.coffee || (echo "Failed to install node modules to cloner. Exiting script."; exit 1)

echo ""
echo "Done."

echo ""
echo 'Zipping site files into "${HOME}/repo/freezeray/cloner/files.zip"...'
zip -rX files.zip files
echo "Done."
echo ""
echo "Delete the folder ${HOME}/repo/freezeray/cloner AFTER you have copied out the site files."
echo "Press Enter to continue."
read -p ""

echo ""
echo "FINAL STEP: Delete the site"
echo 'Once you are sure that the site has been archived successfully, follow the instructions on this page under "Deleting the Site":'
echo "https://sites.google.com/yext.com/consulting-engineering/pages/deactivating-a-site"
echo ""
echo "Press Enter to exit script."
read -p ""