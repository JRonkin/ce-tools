cd $(dirname "${BASH_SOURCE[0]}")
source jira-auth.sh
source timefuncs.sh

usage="Usage: jirasubmit.sh [-hq] [-t api_token] [-u username] jira_number hours [date]"
definitions=(""
	"-h = help"
	"-q = quiet (suppress non-error messages)"
	"-t api_token = JIRA Api Token -- https://id.atlassian.com/manage/api-tokens"
	"-u username = JIRA username (your Yext email address)"
	""
	"jira_number = issue to log time to -- format: PC-XXXXX"
	"hours = time in hours to log (15 minutes = 0.25 hours)"
	"date = date to log hours on -- format: yyyy-mm-dd (default today)"
"")

quiet=""
username=""
apiToken=""

while getopts "hqt:u:" opt
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

		"q" )
			quiet="-q"
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

jira-auth "$username" "$apiToken"

if [ ! $quiet ]
then
	echo "Logging ${hours} hours to issue ${jiranum} as ${username}..."
fi

response=$(curl -so /dev/null -w '%{http_code}' \
  --request POST \
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
  \"started\": \"${date}T12:00:00.000$(date +%z)\",
  \"timeSpentSeconds\": $(hours2seconds $hours)
}")

case "$response" in
	2* )
		echo "Succeeded with response code ${response}"
	;;

	400 )
		echo "Error (400): Input is invalid (missing or invalid fields)"
		exit 1
	;;

	403 )
		echo "Error (403): User does not have permission to add to this issue's worklog"
		exit 1
	;;

	4*|5* )
		echo "Error: Failed with response code ${response}"
		exit 1
	;;

	* )
		echo "Error: Received unexpected response '${response}'"
		exit 1
	;;
esac

