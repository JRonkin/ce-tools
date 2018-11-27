if [ ! -d src/templates ]
then
	echo "Error: 'src/templates/' not found. Run this script from the root of a repo."
	exit 1
fi

grep -R '\$customByName' src/templates |
	sed $'s/\$customByName\?*/\\\n:/g' |
	grep '^:' |
	sed 's/^:\.\([0-9A-Za-z_]*\).*/\1/g; s/^:\[\([^][]*\)\].*/\1/g; s/^:\[\(.*\)\].*/\1/g' |
	sort -u > CustomFieldAudit.txt
