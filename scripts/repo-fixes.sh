# Run from [repo]/src

# Make messages directory with .gitkeep so new webpack works
mkdir ../messages 2>/dev/null
touch ../messages/.gitkeep

# Move readme file from old location to correct location
mv -n Readme.md ../README.md 2>/dev/null

# Replace bad modernizr hashes with correct hash
sed -E -i '' 's/(https:\/\/github\.com\/[^/]*\/customizr\/tarball\/develop)#[0-9a-f]*/\1/g' yarn.lock

# Convert tabs to spaces in pages.json
sed -i '' $'s/\t/  /g' pages.json

# Bump node version to be compatible with yarn
if [[ "$(cat .node-version)" = 5.* ]]
then
	echo 6.2.1 > .node-version
fi
"$(dirname "${BASH_SOURCE[0]}")"/avn.sh