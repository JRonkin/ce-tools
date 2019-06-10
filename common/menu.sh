#!/usr/bin/env bash
clear-menu() {
	# Restore Terminal state
	stty $originalTTYState &>/dev/null

	# Restore the screen and cursor
	tput rmcup
	tput cnorm

	originalTTYState=''
}

clean-exit() {
	clear-menu
	exit
}

menu() {
	if [ ! "$originalTTYState" ]
	then
		# Save terminal state
		originalTTYState="$(stty -g)"
		tput smcup
	fi

	# Run clean_exit if interrupted
	trap clean-exit EXIT INT SIGHUP SIGINT SIGQUIT SIGTERM

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
	while IFS= read line
	do
		[ ${#line} -gt $width ] && width=${#line}
	done <<< "$header"
	(( width -= 1 ))
	while IFS= read line
	do
		[ ${#line} -gt $width ] && width=${#line}
	done <<< "$options"
	[ $(( width += 5 )) -gt $(tput cols) ] && width=$(tput cols)

	# Print Menu
	local start=1
	local end=1

	tput home
	printf "\033[2J$(seq  -f '=' -s '' $width)\n"

	if [ "$header" ]
	then
		while IFS= read line
		do
			[ ${#line} -gt $(( width - 4 )) ] && line="${line:0:$(( width - 5 ))}…"
			printf "| ${line}$(seq  -f ' ' -s '' $(( $width - 3 - ${#line} )))|\n"
			(( ++start ))
			(( ++end ))
		done <<< "$header"
	fi

	while IFS= read line
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
	if [ $selected -lt 0 ]
	then
		selected=0
	fi
	if [ ! $selected -lt $(( $end - $start )) ]
	then
		selected=$(( $end - $start - 1 ))
	fi
	local cursor=$(( $start + $selected ))

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
