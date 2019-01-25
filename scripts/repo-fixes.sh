# Run from [repo]/src

sed -i "" "s/a15f0296a0a2488177085aec4ff42c7aaf5510ef/7f45419c18d8fefc1378cd1ca00bd2aa3aa501b5/" "yarn.lock"

mv -n Readme.md ../README.md

if [[ "$(cat .node-version)" == 5* ]]
then
	echo 6.2.1 > .node-version
	n 6.2.1
fi
