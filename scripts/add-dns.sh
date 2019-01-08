cd $ALPHA
echo "Current directory: $(pwd)"

branch_name="$(git symbolic-ref HEAD 2>/dev/null)" || branch_name="(no branch name)"
branch_name=${branch_name##refs/heads/}

if ! [ "$branch_name" = "master" ]
then
	echo "Error: alpha must be on branch 'master' to continue."
	exit 1
fi

if [ $(git diff head) ]
then
	echo "Error: unsaved changes on branch 'master' of alpha. Commit or stash your changes to continue."
	exit 1
fi

if ! [ -f octodns/yext-cdn.com.yaml ]
then
	echo "Error: cannot find file ${ALPHA}/octodns/yext-cdn.com.yaml"
	exit 1
fi

read -p "Site Domain (format: 'locations.yext.com'): " domain
if [ "$(grep "^${domain//./\.}:$" octodns/yext-cdn.com.yaml)" ]
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

echo "Pulling alpha..."
git pull

echo "Inserting new domain into ${ALPHA}/octodns/yext-cdn.com.yaml..."
>octodns/yext-cdn.com.yaml.tmp
inserted=""
while IFS= read line
do
	if [[ ! "$line" == "  "* ]] && [ ! $inserted ] && [[ "$domain" < "$line" ]]
	then
		echo "${domain}:" >> octodns/yext-cdn.com.yaml.tmp
		if [ "$ttl" ]
		then
			echo "  ttl: ${ttl}" >> octodns/yext-cdn.com.yaml.tmp
		fi
		echo "  type: ${type}" >> octodns/yext-cdn.com.yaml.tmp
        echo "  value: ${value}" >> octodns/yext-cdn.com.yaml.tmp
        inserted=true
	fi
	echo "$line" >> octodns/yext-cdn.com.yaml.tmp

done < octodns/yext-cdn.com.yaml

if [ ! $inserted ]
then
	echo "${domain}:" >> octodns/yext-cdn.com.yaml.tmp
	echo "  type: ${type}" >> octodns/yext-cdn.com.yaml.tmp
    echo "  value: ${value}" >> octodns/yext-cdn.com.yaml.tmp
fi

mv octodns/yext-cdn.com.yaml.tmp octodns/yext-cdn.com.yaml

echo "Creating new commit for octodns/yext-cdn.com.yaml..."
git add octodns/yext-cdn.com.yaml

echo ""
echo "COMMIT MESSAGE FORMAT:"
echo "'yext-cdn octodns: Add BRAND_NAME'"
echo "Replace 'BRAND_NAME' with the name of the brand you're adding."
echo "Once your message is saved, you will be prompted for a JIRA number."
read -p "Press Enter to continue...
"
git commit
git up

echo "Done. Get your CR reviewed on Gerrit and ship it to complete the process."