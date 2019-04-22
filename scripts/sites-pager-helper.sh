domain="$1"

if [ ! "$domain" ]
then
	read -p "Site Domain: " domain
fi

sites-pager -m prod -d "${1}${domain}" -e staging -l "$(dirname $(pwd))" —staticdirs 'src/.tmp' —templatedir 'src/templates'