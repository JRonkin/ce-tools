hash() {
	cksum <<< "$1" | cut -d ' ' -f 1
}

trash() {
	if [ "$1" ]
	then
		file="$1"

		if [ ! -f "$file" ] && [ ! -d "$file" ]
		then
			echo "trash: ${file}: No such file or directory" >&2
		else
			pushd $(dirname "$file")
			osascript -e "tell app \"Finder\" to delete POSIX file \"$(pwd)/$(basename "$file")\"" 1>/dev/null
			popd
		fi
	fi
}