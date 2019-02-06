# Set constants

#S3 bucket for site files
BUCKET="yext-sites-us2-prod"

# Maximum number of concurrent downloads
MAX_CONCURRENT=10


# Function to encode file name
# Alternate encoding that escapes more characters:
# php -r "echo urlencode(\"$@\");"
encode-filename () {
	echo "$@" | sed 's/\//%2F/g; s/@/%40/g'
}


# Get arguments

domain="$1"
if [ ! "$domain" ]
then
	echo
	read -p "Enter the site domain to be downloaded: " domain
fi

folder="$2"


# Authenticate with AWS
echo "Getting AWS credentials..."

awscli sts get-caller-identity


# Find folder(s) to download
spath="s3://${BUCKET}/${domain}/prod/"
allfolders="$(awscli s3 ls "s3://${BUCKET}/${domain}/prod/" | grep PRE | sed 's/^ *PRE \([^\/]*\).*/\1/')"

while [ ! "$(echo "$allfolders" | grep -e '^'"$folder"'$')" ]
do
	echo "Found the following folders:"
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "$allfolders"
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	read -p "Type the name of the folder to download: " folder
done

spath="${spath}${folder}/"


# Working directory for this script
cwd="$(pwd)"


# Download files to temporary directory
# Files whose names are the same as directories will be skipped, and their names saved in $conflicts

echo "Downloading files..."

conflicts="$(awscli s3 sync "$spath" "${cwd}/${domain}_files_tmp" 2>&1 >/dev/null | grep "Errno 21" | cut -d ' ' -f 3 | cut -c $((${#spath} + 1))-)"

mkdir "${domain}_files"


# Download the conflicting files individually
# Can be done in the background while URL-encoding other files

if [ "$conflicts" ]
then
	(
		concurrent=0

		while read filename
		do
			awscli s3 cp "${spath}${filename}" "${cwd}/${domain}_files/$(encode-filename "$filename")" >/dev/null &

			if [ ! $(( concurrent++ )) -lt $MAX_CONCURRENT ]
			then
				concurrent=0
				wait
			fi
		done <<< "$conflicts"
	) &
fi


# URL-encode the paths and names of the downloaded files and move to output directory

echo "URL-encoding filenames..."

cd "${domain}_files_tmp"

files="$(find . -type f | cut -c 3-)"
numfiles=$(echo "$files" | wc -l | tr -d ' ')
completed=0
counter=0
onepercent=$(( $numfiles / 100 ))

echo -ne "\r0%"
while read filename
do
	mv "$filename" "../${domain}_files/$(encode-filename "$filename")"

	if [ $((counter++)) -gt $onepercent ]
	then
		echo -ne "\r$(( (completed += $counter) * 100 / $numfiles ))%\033[0K"
		counter=0
	fi
done <<< "$files"
echo -ne "\r\033[0K"

cd ..
rm -R "${domain}_files_tmp"


# Wait for download conflicting files background process to finish
if [ "$conflicts" ]
then
	echo "Resolving $(echo "$conflicts" | wc -l | tr -d ' ') file/directory name conflicts..."
	wait
fi


# Zip files
echo "Compressing files into '${domain}.zip'..."
cd "${domain}_files"
zip -qrX "${domain}.zip" $(ls)
mv "${domain}.zip" ..
cd ..
rm -R "${domain}_files"


echo "Done!"
