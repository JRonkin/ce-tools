source ../common/funcs.sh
source jira-auth.sh

tempo-auth() {
  jiraorg="$1"
  username="$2"
  apiToken="$3"

  jira-auth "$jiraorg" "$username" "$apiToken"

  tempoToken="$4"
  savedToken="$(security find-generic-password -s 'TimeLog' -l 'Tempo API token' -a "Tempo ${jiraorg}" -w 2>/dev/null)"

  tempoJiraAccount="$(security find-generic-password -s 'TimeLog' -l 'Tempo API token' -a "Tempo ${jiraorg}" 2>/dev/null |
    grep '"icmt"' |
    cut -d = -f 2 |
    grep -v '^<NULL>$' |
    tr -d '"')"

  if [ ! "$tempoJiraAccount" ]
  then
    tempoJiraAccount="$(readJSON "$(curl \
      --silent \
      --request 'GET' \
      --url "https://${jiraorg}.atlassian.net/rest/api/3/user/search?username=${username}" \
      --user "${username}:${apiToken}" \
      --header 'Accept: application/json')" "[0]['accountId']")"
  fi

  if [ "$tempoToken" ]
  then
    if [ "$savedToken" ] && [ ! "$tempoToken" = "$savedToken" ]
    then
      echo 'The given Tempo token does not match the saved token.'
      if [[ "$(read -p 'Update saved token? (y/N) ' ans; echo "$ans")" =~ ^[Yy]([Ee][Ss])?$ ]]
      then
        security add-generic-password -s 'TimeLog' -l 'Tempo API token' -j "$tempoJiraAccount" -a "Tempo ${jiraorg}" -w "$tempoToken" -U
      fi
    fi
  else
    if [ "$savedToken" ]
    then
      tempoToken="$savedToken"
    else
      echo 'Enter your Tempo API token'
      echo "If you haven't created a token yet, create one here:"
      echo "https://${jiraorg}.atlassian.net/plugins/servlet/ac/io.tempo.jira/tempo-configuration#!/api-integration"

      while [ ! "$tempoToken" ]
      do
        read -sp 'API Token: ' tempoToken
        echo
      done

      if [[ "$(read -p 'Save your token in Keychain? (y/N) ' ans; echo "$ans")" =~ ^[Yy]([Ee][Ss])?$ ]]
      then
        security add-generic-password -s 'TimeLog' -l 'Tempo API token' -j "$tempoJiraAccount" -a "Tempo ${jiraorg}" -w "$tempoToken" -U
      fi
    fi
  fi
}
