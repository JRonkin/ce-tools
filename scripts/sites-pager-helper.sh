read -p "Site Domain: " domain

sites-pager -m prod -d "$domain" -e production -l "$(pwd)" —staticdirs src/.tmp —templatedir src/templates