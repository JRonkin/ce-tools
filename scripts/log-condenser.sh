source "$(dirname "${BASH_SOURCE[0]}")/../common/timefuncs.sh"

#S3 bucket for log files
BUCKET='yext-global-logs-prod'

usage='Usage: log-condenser.sh [-h] [-i include] [-e exclude] start_date end_date [output_directory]'
definitions=(''
  '-h = help'
  ''
  '-i include = only include logs with the given string'
  '-e exclude = exclude logs with the given string'
  ''
  'start_date = start of date range, in yyyy-mm-dd format'
  'end_date = end of date range'
  'output_directory = directory to save the logs in (default cloudflare_logs)'
'')

include=''
exclude=''

while getopts "hi:e:" opt
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

    "i" )
      include="$OPTARG"
    ;;

    "e" )
      exclude="$OPTARG"
    ;;

    * )
      exit 1
    ;;
  esac
done

shift $((OPTIND-1))

if [ ! "$1" ]
then
  echo 'Error: missing start date'
  exit 1
fi
start="$(date -ju -f '%Y-%m-%d' "$1" '+%Y-%m-%d')"
if [ ! "$start" ]
then
  echo 'Error: invalid start date. Date must be in the format yyyy-mm-dd'
  exit 1
fi

if [ ! "$2" ]
then
  echo 'Error: missing end date'
  exit 1
fi
end="$(date -ju -f '%Y-%m-%d' "$2" '+%Y-%m-%d')"
if [ ! "$start" ]
then
  echo 'Error: invalid end date. Date must be in the format yyyy-mm-dd'
  exit 1
fi

output_directory='cloudflare_logs'
if [ "$3" ]
then
  output_directory="$3"
fi


# Authenticate with AWS
echo 'Getting AWS credentials...'

awscli sts get-caller-identity


mkdir "$output_directory"
cd "$output_directory"

# Working directory for this script
cwd="$(pwd)"

rm -rf "${cwd}/temp"

while read epoch
do
  day="$(epoch2date $epoch)"

  # Download log files for a day
  spath="s3://${BUCKET}/cloudflare/sitescdn.net/${day//-}/"

  echo "Downloading files for ${day}..."
  awscli s3 sync "$spath" "${cwd}/temp/${day//-}"


  # Search logs for include/exclude and save to output file
  echo "Processing logs for ${day}..."

  files="$(ls ${cwd}/temp/${day//-}/*.gz)"
  numfiles=$(echo "$files" | wc -l | tr -d ' ')
  completed=0
  echo -ne "\r0%"

  while read zippedlog
  do
    gunzip "$zippedlog"
    logfile="${zippedlog%.*}"

    if [ "$exclude" ]
    then
      cat "${logfile}" | grep "$include" | grep -v "$exclude" >> "${cwd}/${day//-}.log"
    else
      cat "${logfile}" | grep "$include" >> "${cwd}/${day//-}.log"
    fi

    rm "${logfile}"

    echo -ne "\r$(( ++completed * 100 / $numfiles ))%\033[0K"
  done <<< "$files"

  echo -ne "\r\033[0K"

  echo "Zipping output file '${day//-}.log'..."
  gzip "${cwd}/${day//-}.log"

  echo 'Done.'

  rm -rf "${cwd}/temp/${day//-}"
done <<< "$(seq -f %f $(date2epoch $start) 86400 $(date2epoch $end) | cut -d . -f 1) "

rm -rf "${cwd}/temp"
