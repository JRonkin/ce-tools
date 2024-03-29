jira-auth() {
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

  username="$2"
  if [ ! "$username" ]
  then
    username="$(security find-generic-password -s 'TimeLog' -l 'JIRA API token' 2>/dev/null | grep '"acct"' | cut -d = -f 2 | tr -d '"')"

    while [ ! "$username" ]
    do
      read -p 'JIRA Username: ' username
    done
  fi

  apiToken="$3"
  savedToken="$(security find-generic-password -s 'TimeLog' -a "$username" -w 2>/dev/null)"

  if [ "$apiToken" ]
  then
    if [ "$savedToken" ] && [ ! "$apiToken" = "$savedToken" ]
    then
      echo "The given API token does not match the saved token for '${username}'."
      if [[ "$(read -p 'Update saved token? (y/N) ' ans; echo $ans)" =~ ^[Yy]([Ee][Ss])?$ ]]
      then
        security add-generic-password -s 'TimeLog' -l 'JIRA API token' -j "$jiraorg" -a "$username" -w "$apiToken" -U
      fi
    fi
  else
    if [ "$savedToken" ]
    then
      apiToken="$savedToken"
    else
      echo "Enter your JIRA API token for ${username}"
      echo "If you haven't created a token yet, create one here:"
      echo 'https://id.atlassian.com/manage-profile/security/api-tokens'

      while [ ! "$apiToken" ]
      do
        read -sp 'API Token: ' apiToken
        echo
      done

      if [[ "$(read -p 'Save your token in Keychain? (y/N) ' ans; echo $ans)" =~ ^[Yy]([Ee][Ss])?$ ]]
      then
        security add-generic-password -s 'TimeLog' -l 'JIRA API token' -j "$jiraorg" -a "$username" -w "$apiToken" -U
      fi
    fi
  fi
}
