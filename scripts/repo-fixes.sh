# Run from [repo]/src

# Make messages directory with .gitkeep so new webpack works
mkdir ../messages 2>/dev/null
touch ../messages/.gitkeep

# Move readme file from old location to correct location
mv -n Readme.md ../README.md 2>/dev/null

# Replace bad modernizr hashes with correct hash
sed -E -i "" "s/a15f0296a0a2488177085aec4ff42c7aaf5510ef|bf72bdbc0e693e253cfc2b80180eb7b984753111|75b0a85e5de99918bb6219227b283002f87546f1|7f45419c18d8fefc1378cd1ca00bd2aa3aa501b5/2fb79b5e0952f3d2d46b7c5a665e64e2f5e75a2e/g" yarn.lock

# Convert tabs to spaces in pages.json
sed -i "" $'s/\t/  /g' pages.json

# Bump node version to be compatible with yarn
if [[ "$(cat .node-version)" = 5.* ]]
then
	echo 6.2.1 > .node-version
fi
"$(dirname "${BASH_SOURCE[0]}")"/avn.sh