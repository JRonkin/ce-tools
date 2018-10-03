usage="Usage: fix-yarn-modernizr.sh [-h] [file]"
definitions=("-h = help" "file = file with path, default ./yarn.lock")

while getopts "h" opt
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

		* )
			exit 1
		;;
	esac
done

file="$1"
if [ ! "$file" ]
then
	file=yarn.lock
fi

sed -i "" "s/a15f0296a0a2488177085aec4ff42c7aaf5510ef/7f45419c18d8fefc1378cd1ca00bd2aa3aa501b5/" "$file"