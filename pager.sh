# This is a shell script that converts pager calls into sites-pager calls.
# Supported Pager options are:
# * pagesdir
# * port (default '9027')
# * staticdirs (default 'desktop')
# * templatedir (default 'templates')
# All other Pager arguments are ignored.


# Pager parameters

# flags
compileonly=''
mobile=''
nosecure=''
nostats=''
pull=''
watch=''

# values
i18nDataPath=''
log_backtrace_at=''
pagesdir=''
port='9027'
srcdir='src'
staticdirs='desktop'
templatedir='templates'
v=''
vmodule=''

# Read the Pager arguments
while [ $# -gt 0 ]
do
	case "$1" in
		"--pagesdir" )
			shift 
			pagesdir="$1"
		;;

		"--port="* )
			port="$(cut -d '=' -f 2 <<< "$1")"
		;;

		"--staticdirs" )
			shift 
			staticdirs="$1"
		;;

		"--templatedir" )
			shift 
			templatedir="$1"
		;;

		* )
			echo "Warning: Ignoring unsupported argument '${1}'" > 2
		;;
	esac

	shift 1
done

# Get list of domains for the repo
repo="$(basename "$pagesdir")"
domains="$(export YEXT_SITE='nj1'; sites-list -repo="$repo" | grep "hostname: " | cut -d ':' -f 2 | tr -d ' ')"

# Present the list of domains to choose from
echo ""
counter=0
if [ "$domains" ]
then
	while read domain
	do
		counter=$(( $counter + 1 ))
		echo "${counter}: ${domain}"
		domainslist[$counter]="$domain"
	done <<< "$domains"
else
	echo "No sites found for this repo:"
	echo "${repo}"
	exit
fi

if [ $counter -eq 1 ]
then
	num=$counter
else
	echo ""
	read -p "Site #: " num
fi

if [[ ! "$num" =~ [0-9]+ ]] || [ $num -lt 1 ] || [ $num -gt $counter ]
then
	echo "Invalid selection."
	exit
fi

# Run sites-pager with the given options and domain
sites-pager -m 'prod' -d "${domainslist[$num]}" -e 'staging' -l "$pagesdir" --staticdirs "$staticdirs" --templatedir "$templatedir" -p "$port"
