tempo-auth() {
  jiraorg="$1"
  if [ ! "$jiraorg" ]
  then
    jiraorg="$(security find-generic-password -s 'TimeLog' -l 'JIRA API token' 2>/dev/null |
      grep '"icmt"' |
      cut -d = -f 2 |
      grep -v '^<NULL>$' |
      tr -d '"')"

    while [ ! "$jiraorg" ]
    do
      read -p 'JIRA Organization (XXX in https://XXX.atlassian.net): ' jiraorg
    done
  fi

  tempoToken="$2"
  savedToken="$(security find-generic-password -s 'TimeLog' -a "Tempo ${jiraorg}" -w 2>/dev/null)"

  if [ "$tempoToken" ]
  then
    if [ "$savedToken" ] && [ ! "$tempoToken" = "$savedToken" ]
    then
      echo 'The given Tempo token does not match the saved token.'
      if [[ "$(read -p 'Update saved token? (y/N) ' ans; echo "$ans")" =~ ^[Yy]([Ee][Ss])?$ ]]
      then
        security add-generic-password -s 'TimeLog' -a "Tempo ${jiraorg}" -l 'Tempo API token' -w "$tempoToken" -U
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
        security add-generic-password -s 'TimeLog' -a "Tempo ${jiraorg}" -l 'Tempo API token' -w "$tempoToken" -U
      fi
    fi
  fi
}
