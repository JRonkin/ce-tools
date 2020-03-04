cd $(dirname "${BASH_SOURCE[0]}")
source ../common/funcs.sh
source ../common/timefuncs.sh
source tempo-auth.sh

usage='Usage: jirasubmit.sh [-hq] [-o jira_org] [-u username [-t jira_api_token]] [-T tempo_api_token] jira_number hours [date]'
definitions=(''
  '-h = help'
  '-q = quiet (suppress non-error messages)'
  ''
  '-o jira_org = JIRA organization (XXX in https://XXX.atlassian.net)'
  '-u username = JIRA username (your email address)'
  '-t jira_api_token = JIRA API Token -- https://id.atlassian.com/manage/api-tokens'
  ''
  '-T tempo_api_token = Tempo API Token'
  ''
  'jira_number = issue to log time to -- format: PC-XXXXX'
  'hours = time in hours to log (15 minutes = 0.25 hours)'
  'date = date to log hours on -- format: yyyy-mm-dd (default today)'
'')

quiet=
jiraorg=
username=
apiToken=
tempoToken=

while getopts 'hqo:T:t:u:' opt
do
  case "$opt" in
    'h' )
      echo "${usage}"
        for i in "${definitions[@]}"
        do
          echo "$i"
        done
      exit
    ;;

    'o' )
      jiraorg="$OPTARG"
    ;;

    'q' )
      quiet='-q'
    ;;

    'u' )
      username="$OPTARG"
    ;;

    'T' )
      tempoToken="$OPTARG"
    ;;

    't' )
      apiToken="$OPTARG"
    ;;

    * )
      exit 1
    ;;
  esac
done

if [ ! "$username" ]
then
  apiToken=''
fi

shift $((OPTIND-1))

if [ $# -lt 2 ] || [ $# -gt 3 ]
then
  echo 'Error: incorrect number of arguments.'
  ./jirasubmit.sh -h
  exit 1
fi

jiranum="$1"

hours="$2"
if [[ ! "$hours" =~ ^[0-9]*\.?[0-9]*$ ]]
then
  echo 'Error: invalid number of hours. Hours must be a positive decimal number.'
  exit 1
fi

if [ "$3" ]
then
  date="$(date -ju -f '%Y-%m-%d' "$3" '+%Y-%m-%d')"
  if [ ! "$date" ]
  then
    echo 'Error: invalid date. Date must be in the format yyyy-mm-dd.'
    exit 1
  fi
else
  date="$(date '+%Y-%m-%d')"
fi

tempo-auth "$jiraorg" "$username" "$apiToken" "$tempoToken"

if [ ! $quiet ]
then
  echo "Logging ${hours} hours to issue ${jiranum} as ${username}..."
fi

tempoAccountId="$(readJSON "$(curl \
  --silent \
  --request 'GET' \
  --url "https://${jiraorg}.atlassian.net/rest/api/3/issue/${jiranum}" \
  --user "${username}:${apiToken}" \
  --header 'Accept: application/json')" "['fields']['customfield_11000']['id']")"

# Check the cache of tempo accounts for the ID
tempoAccountsFile="../appdata/timelog/tempo_accounts/${jiraorg}"
if [ -f "$tempoAccountsFile" ]
then
  tempoAccount="$(grep "^${tempoAccountId}," "$tempoAccountsFile" | cut -d ',' -f 2)"
fi

# Update the tempo account cache and check again
if [ ! "$tempoAccount" ]
then
  allTempoAccounts="$(curl \
    --silent \
    --request 'GET' \
    --url 'https://api.tempo.io/core/3/accounts' \
    --header "Authorization: Bearer ${tempoToken}" \
    --header 'Accept: application/json')"

  [ -d "$(dirname "$tempoAccountsFile")" ] || mkdir -p "$(dirname "$tempoAccountsFile")"

  echo "$allTempoAccounts" | python -c "
import json, sys
for account in json.load(sys.stdin)['results']:
  print(str(account['id']) + ',' + account['key'])
  " > "$tempoAccountsFile"

  tempoAccount="$(grep "^${tempoAccountId}" "../appdata/timelog/tempo_accounts/${jiraorg}" | cut -d ',' -f 2)"
fi

response="$(curl \
  --silent \
  --output /dev/null \
  --write-out '%{http_code}' \
  --request 'POST' \
  --url 'https://api.tempo.io/core/3/worklogs' \
  --header "Authorization: Bearer ${tempoToken}" \
  --header 'Content-Type: application/json' \
  --data "{
    \"attributes\": [
      {
        \"key\": \"_Account_\",
        \"value\": \"${tempoAccount}\"
      }
    ],
    \"authorAccountId\": \"${tempoJiraAccount}\",
    \"issueKey\": \"${jiranum}\",
    \"startDate\": \"${date}\",
    \"startTime\": \"12:00:00\",
    \"timeSpentSeconds\": $(hours2seconds $hours)
  }")"

case "$response" in
  2* )
    echo "Succeeded with response code ${response}"
  ;;

  400 )
    echo "Error (400): The worklog can't be created for some reason."
    exit 1
  ;;

  401 )
    echo 'Error (401): You are not authenticated.'
    exit 1
  ;;

  403 )
    echo "Error (403): You don't have permission to submit this worklog."
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
