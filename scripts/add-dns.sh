#!/usr/bin/env bash
DNS_FILE="octodns/yext-cdn.com.yaml"

cd $ALPHA
echo "Current directory: $(pwd)"

branch_name="$(git symbolic-ref HEAD 2>/dev/null)" || branch_name="(no branch name)"
branch_name="${branch_name##refs/heads/}"

if ! [ "$branch_name" = "master" ]
then
	echo "Error: alpha must be on branch 'master' to continue."
	exit 1
fi

if [ "$(git diff head)" ]
then
	echo "Error: unsaved changes on branch 'master' of alpha. Commit or stash your changes to continue."
	exit 1
fi

if ! [ -f $DNS_FILE ]
then
	echo "Error: cannot find file ${ALPHA}/${DNS_FILE}"
	exit 1
fi

echo "Pulling alpha..."
git pull

done=''
while [ ! "$done" ]
do
	read -p "Site Domain (format: 'locations.example.com'): " domain
	if [ "$(grep "^${domain//./\.}:$" ${DNS_FILE})" ]
	then
		echo "'${domain}' is already on record."
		exit
	fi

	read -p "ttl (leave blank to not include): " ttl
	read -p "type (leave blank for default 'CNAME'): " type
	read -p "value (leave blank for default 'cloudflare.sitescdn.net.'): " value
	if ! [ "$type" ]
	then
		type="CNAME"
	fi
	if ! [ "$value" ]
	then
		value="cloudflare.sitescdn.net."
	fi

	echo "Inserting new domain into ${ALPHA}/${DNS_FILE}..."
	>${DNS_FILE}.tmp
	inserted=""
	while IFS= read line
	do
		if [[ ! "$line" == "  "* ]] && [ ! $inserted ] && [[ "$domain" < "$line" ]]
		then
			echo "${domain}:" >> ${DNS_FILE}.tmp
			if [ "$ttl" ]
			then
				echo "  ttl: ${ttl}" >> ${DNS_FILE}.tmp
			fi
			echo "  type: ${type}" >> ${DNS_FILE}.tmp
			echo "  value: ${value}" >> ${DNS_FILE}.tmp
			inserted=true
		fi
		echo "$line" >> ${DNS_FILE}.tmp

	done < ${DNS_FILE}

	if [ ! $inserted ]
	then
		echo "${domain}:" >> ${DNS_FILE}.tmp
		echo "  type: ${type}" >> ${DNS_FILE}.tmp
		echo "  value: ${value}" >> ${DNS_FILE}.tmp
	fi

	mv ${DNS_FILE}.tmp ${DNS_FILE}

	read -p "Add another? (y/N)" done
	if [ "$(echo "$done" | tr "A-Z" "a-z")" = "y" ] || [ "$(echo "$done" | tr "A-Z" "a-z")" = "yes" ]
	then
		done=''
	else
		done='true'
	fi
done

echo "Creating new commit for ${DNS_FILE}..."
git add ${DNS_FILE}

echo
echo "COMMIT MESSAGE FORMAT:"
echo "yext-cdn octodns: Add BRAND_NAME"
echo "J=JIRA_NUMBER"
echo
echo "Replace 'BRAND_NAME' with the name of the brand you're adding."
echo "Replace 'JIRA_NUMBER' with the JIRA number for the item, e.g. 'PC-12345'."
read -p "Press Enter to continue...
"
git commit
git up

echo "Done. Get your CR reviewed on Gerrit and ship it to complete the process."
