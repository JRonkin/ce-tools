while [ "$1" ]
do
  file="$1"

  if [ ! -f "$file" ] && [ ! -d "$file" ]
  then
    echo "trash: ${file}: No such file or directory" >&2
  else
    osascript -e "tell app \"Finder\" to delete POSIX file \"$(realpath "$file")\"" 1>/dev/null &
  fi

  shift
done

wait
