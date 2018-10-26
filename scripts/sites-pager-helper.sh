if [ ! "$1" ]; then read -p "Site Domain: " domain; fi

sites-pager -m prod -d "${1}${domain}" -e staging -l "$(dirname $(pwd))" —staticdirs 'src/.tmp' —templatedir 'src/templates'