cd $(dirname "${BASH_SOURCE[0]}")
source timefuncs.sh

usage="Usage: jirasubmit.sh [-h] [-u username] [-t api_token] jira_number hours [date]"
definitions=("" "-h = help" "-u username = JIRA username (your Yext email address)" "-t api_token = JIRA Api Token -- https://id.atlassian.com/manage/api-tokens" "" "jira_number = issue to log time to -- format: PC-XXXXX" "hours = time in hours to log (15 minutes = 0.25 hours)" "date = date to log hours on -- format: yyyy-mm-dd (default today)")

username=""
apiToken=""

while getopts "ht:u:" opt
do
	case "$opt" in
		"h" )
			echo "${usage}"
				for i in "${definitions[@]}"
				do
					echo "$i"
				done
			exit
		;;

		"t" )
			apiToken="$OPTARG"
		;;

		"u" )
			username="$OPTARG"
		;;

		* )
			exit 1
		;;
	esac
done

shift $((OPTIND-1))

if [ $# -lt 2 ] || [ $# -gt 3 ]
then
	echo "Error: incorrect number of arguments."
	./jirasubmit.sh -h
	exit 1
fi

jiranum="$1"

hours="$2"
if [[ ! "$hours" =~ ^[0-9]*\.?[0-9]*$ ]]
then
	echo "Error: invalid number of hours. Hours must be a positive decimal number."
	exit 1
fi

if [ "$3" ]
then
	date="$(date -ju -f "%Y-%m-%d" "$3" "+%Y-%m-%d")"
	if [ ! "$date" ]
	then
		echo "Error: invalid date. Date must be in the format yyyy-mm-dd."
		exit 1
	fi
else
	date="$(date "+%Y-%m-%d")"
fi

if [ ! "$username" ]
then
	read -p "Username: " username
fi
if [ ! "$apiToken" ]
then
	read -sp "API Token: " apiToken
fi

curl --request POST \
  --url https://yexttest.atlassian.net/rest/api/3/issue/${jiranum}/worklog \
  --user ${username}:${apiToken} \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --data "{
  \"comment\": {
    \"type\": \"doc\",
    \"version\": 1,
    \"content\": [
      {
        \"type\": \"paragraph\",
        \"content\": [
          {
            \"type\": \"text\",
            \"text\": \"Working on issue ${jiranum}\"
          }
        ]
      }
    ]
  },
  \"started\": \"${date}T00:00:00.000+0000\",
  \"timeSpentSeconds\": $(hours2seconds $hours)
}"
