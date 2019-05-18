clear_menu() {
	# Restore Terminal state
	stty $original_tty_state

	# Restore the screen and cursor
	tput rmcup
	tput cnorm

	original_tty_state=''
}

clean_exit() {
	clear_menu
	exit
}

menu() {
	if [ ! "$original_tty_state" ]
	then
		# Save terminal state
		original_tty_state="$(stty -g)"
		tput smcup
	fi

	# Run clean_exit if interrupted
	trap clean_exit EXIT INT SIGHUP SIGINT SIGQUIT SIGTERM

	# Hide input and cursor
	stty -echo
	tput civis

	local header="$1"
	shift
	local options="$1"
	shift
	local selected=0$1
	shift
	local optionsArray=()

	local triggers=()
	local input
	while [ "$1" ]
	do
		input="$(echo "$1" | tr 'a-z' 'A-Z')"
		triggers[$(printf %d \'$input)]=true
		shift 1
	done

	local width=0
	local line
	while read line
	do
		[ ${#line} -gt $width ] && width=${#line}
	done <<< "$header"
	(( width -= 1 ))
	while read line
	do
		[ ${#line} -gt $width ] && width=${#line}
	done <<< "$options"
	[ $(( width += 5 )) -gt $(tput cols) ] && width=$(tput cols)

	# Print Menu
	local start=1
	local end=1

	tput home
	printf "\033[2J$(seq  -f '=' -s '' $width)\n"

	while read line
	do
		if [ "$line" ]
		then
			[ ${#line} -gt $(( width - 4 )) ] && line="${line:0:$(( width - 5 ))}…"
			printf "| ${line}$(seq  -f ' ' -s '' $(( $width - 3 - ${#line} )))|\n"
			(( ++start ))
			(( ++end ))
		fi
	done <<< "$header"

	while read line
	do
		if [ "$line" ]
		then
			if [ $end = $start ] && [ $start -gt 1 ]
			then
				printf "|$(seq  -f '-' -s '' $(( $width - 2 )))|\n"
				(( ++start ))
				(( ++end ))
			fi

			[ ${#line} -gt $(( width - 5 )) ] && line="${line:0:$(( width - 6 ))}…"
			printf "|  ${line}$(seq  -f ' ' -s '' $(( $width - 4 - ${#line} )))|\n"
			optionsArray[${#optionsArray[@]}]="$line"
			(( ++end ))
		fi
	done <<< "$options"

	printf "$(seq  -f '=' -s '' $width)\n"

	# Set Cursor
	local cursor=$(( $start + $selected ))
	if [ $cursor -lt $start ]
	then
		cursor=$start
	fi
	if [ ! $cursor -lt $end ]
	then
		cursor=$(( $end - 1 ))
	fi

	if [ ! $cursor -lt $start ]
	then
		tput cup $cursor 2
		printf '>'
		tput cup $cursor 2
	fi

	# UI Loop
	while :
	do
		IFS= read -n 1 input

		if [ "$input" = "" ]
		then
			read -n 2 -t 1 input

			case "$input" in
				# Up arrow
				"[A" )
					if [ $(( --cursor )) -lt $start ]
					then
						cursor=$(( $end - 1 ))
					fi
				;;
				# Down Arrow
				"[B" )
					if [ ! $(( ++cursor )) -lt $end ]
					then
						cursor=$start
					fi
				;;
			esac

			if [ ! $cursor -lt $start ] && [ $cursor -lt $end ]
			then
				printf ' '
				tput cup $cursor 2
				printf '>'
				tput cup $cursor 2
				selected=$(( $cursor - $start ))
			fi
		else
			input="$(echo "$input" | tr 'a-z' 'A-Z')"
			if [ ! "$input" ] || [ "${triggers[$(printf %d \'$input)]}" ]
			then
				menu_key="$input"
				menu_selected=$selected
				menu_value="${optionsArray[$selected]}"
				break
			fi
		fi
	done
}
