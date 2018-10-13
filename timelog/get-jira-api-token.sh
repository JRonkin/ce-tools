if [ "$1" = "-h" ]
then
	echo "Usage: get-jira-api-token.sh username"
	exit
fi

if [ ! $# -eq 1 ]
then
	echo "Error: incorrect number of arguments."
	echo "Usage: get-jira-api-token.sh username"
	exit 1
fi

username="$1"
token="$(security find-generic-password -s "TimeLog" -a "$username" -w)"

if [ ! "$token" ]
then
	echo "Enter your JIRA API token for ${username}"
	echo "If you haven't created a token yet, create one here:"
	echo "https://id.atlassian.com/manage/api-tokens"

	while [ ! "$token" ]
	do
		read -sp "API Token: " token
		echo ""
	done

	read -p "Save your token in Keychain? (y/N) " saveToken
	if [[ "$saveToken" =~ ^[Yy]([Ee][Ss])?$ ]]
	then
		security add-generic-password -s "TimeLog" -a "$username" -l "JIRA API token" -p "$token" -U
	fi
fi

echo "$token"