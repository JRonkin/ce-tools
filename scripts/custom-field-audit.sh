if [ ! -d src/templates ]
then
	echo "Error: 'src/templates/' not found. Run this script from the root of a repo."
	exit 1
fi

soy="$(grep -R -e '[^ ]customByName' src/templates |
	sed $'s/customByName\?*/\\\n:/g' |
	grep -e '^:[.[]' |
	sed 's/^:\.\([0-9A-Za-z_]*\).*/\1/g; s/^:\[\([^][]*\)\].*/\1/g; s/^:\[\(.*\)\].*/\1/g' |
	sort -u)"

js="$(grep -R 'customByName' src/js)"

coffee="$(grep -R 'customByName' src/coffee)"

[ -f CustomFieldAudit.txt ] && rm CustomFieldAudit.txt

if [ "$soy" ]
then
	echo "~~~~~ SOY ~~~~~" >> CustomFieldAudit.txt
	echo "$soy" >> CustomFieldAudit.txt
fi

if [ "$js" ]
then
	echo "~~~~~ JS ~~~~~" >> CustomFieldAudit.txt
	echo "$js" >> CustomFieldAudit.txt
fi

if [ "$coffee" ]
then
	echo "~~~~~ COFFEE ~~~~~" >> CustomFieldAudit.txt
	echo "$coffee" >> CustomFieldAudit.txt
fi
