# Run from [repo]/src

sed -E -i "" "s/a15f0296a0a2488177085aec4ff42c7aaf5510ef|bf72bdbc0e693e253cfc2b80180eb7b984753111|75b0a85e5de99918bb6219227b283002f87546f1/7f45419c18d8fefc1378cd1ca00bd2aa3aa501b5/g" yarn.lock

sed -i "" $'s/\t/  /g' pages.json

mv -n Readme.md ../README.md

if [[ "$(cat .node-version)" == 5* ]]
then
	echo 6.2.1 > .node-version
	n 6.2.1
fi
