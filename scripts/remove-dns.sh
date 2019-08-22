domain="$1"

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

if [ ! "$domain" ]
then
  read -p "Site Domain (format: 'locations.example.com'): " domain
fi

if [ ! "$(cat "$DNS_FILE" | grep "^${domain}:\$")" ]
then
  echo "Entry for '${domain}' not found."
  exit
fi

>${DNS_FILE}.tmp
deleting=''
while IFS= read line
do
  if [[ ! "$line" == "  "* ]]
  then
    deleting=''
  fi

  if [ ! $deleting ] && [[ ! "$line" == "${domain}:" ]]
  then
    echo "$line" >> ${DNS_FILE}.tmp
  else
    deleting=true
  fi
done < ${DNS_FILE}

mv ${DNS_FILE}.tmp ${DNS_FILE}

echo "Creating new commit for ${DNS_FILE}..."
git add "$DNS_FILE"

echo
echo "COMMIT MESSAGE FORMAT:"
echo "yext-cdn octodns: Remove BRAND_NAME"
echo "J=JIRA_NUMBER"
echo
echo "Replace 'BRAND_NAME' with the name of the brand you're removing."
echo "Replace 'JIRA_NUMBER' with the JIRA number for the item, e.g. 'PC-12345'."
read -p "Press Enter to continue...
"
git commit
git up

echo "Done. Get your CR reviewed on Gerrit and ship it to complete the process."
