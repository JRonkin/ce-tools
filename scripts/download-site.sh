die() { echo "$@" >&2; exit 1; }

echo ""
echo "Visit this page if you have not set up AWSCLI:"
echo "https://sites.google.com/yext.com/consulting-engineering/engineering/3-10-aws/aws-cli-setup"
echo ""
echo "Once AWSCLI is set up, press Enter."
read -p ""

echo ""
echo "Getting temporary AWS credentials..."
echo "Choose Legacy-Consulting when prompted."
export AWS_PROFILE=''
awscli logout && awscli sts get-caller-identity || die "Failed to get AWS credentials. Exiting script."

git clone "ssh://git@stash.office.yext.com:1234/con/freezeray.git" "${HOME}/repo/freezeray" && cd "${HOME}/repo/freezeray/cloner" || die "Cloning freezeray failed. Exiting script."
npm install || die "Failed to install node modules to cloner. Exiting script."
mkdir files

echo ""
read -p "Enter the site domain to be downloaded: " domain

echo ""
read -p "Is the site adaptive? (Y/n)" adaptive
if [ "$(echo "$adaptive" | tr A-Z a-z)" = "n" ] || [ "$(echo "$adaptive" | tr A-Z a-z)" = "no" ]
then
	echo "Site is NOT adaptive."
	sed -i "" 's/PREFIX = domain \+ "\/prod\/desktop\/"/PREFIX = domain \+ "\/prod\/"/' index.coffee
else
	echo "Site IS adaptive."
fi

echo "Downloading site files..."
$(npm bin)/coffee index.coffee --domain "$domain" || die "Failed to download files. Exiting script."
echo ""
echo "Done."

echo ""
echo "Zipping site files into '${HOME}/repo/freezeray/cloner/${domain}.zip'..."
mv files "$domain"
zip -qrX "${domain}.zip" "$domain"
echo "Done."
echo ""
echo "Site download complete!"
echo "Delete the folder ${HOME}/repo/freezeray/cloner AFTER you have copied out the site files."
echo "Press Enter to finish."
read -p ""