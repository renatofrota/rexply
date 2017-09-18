#!/bin/bash
# reXply 0.0.2
# version number not updated on minor changes
# @link https://github.com/renatofrota/rexply

# INSTALLATION
# clone repo, symlink the binary at a directory in your $PATH

# EXAMPLE
# cd ~/ ; git clone https://github.com/renatofrota/rexply.git
# ln -s ~/rexply/rexply.bash $(echo $PATH|cut -d: -f1)/rexply
# echo "reXply installed to $(echo $PATH|cut -d: -f1)/rexply"

# ENVIRONMENT CONFIGURATION
# set keyboard shortcuts to
# "rexply" start reXply from default 'rexply-data/repository'
# "rexply -R subfolder" init from a repository's subdirectory
# "rexply -R /absolute/path" > init from any other given path
# "rexply -R subfolder/file" very to the point: just paste it

deptest="1" # check if all dependencies are installed
# see README.md footnotes for more information on how
# to circumvent the dependencies by changing settings

cbackup='1' # backup current clipboard data (internal script variable) before doing anything else!
copytoc='1' # copy processed data (importing template, processing frontmatter, etc..) to clipboard
# before you ask: one may be interested in using reXply just to process the data then use $tmpfile
focusit='1' # focus the window before pasting - prevents unwanted pastes to always-on-top windows!
# note: by disabling 'focusit' option the default clipboard and paste command will always be used!
# eliminates the xdotool dependency - useful in OSX - but you will need to paste the data manually
pasteit='1' # truly (and automatically) paste data after you select source file and it's processed
restore='1' # restore original clipboard data - disabling this you can paste data many other times
killtmp='1' # kill the tmpfile after pasting. disable it if you want to [re]use the processed data
copycmd='1' # use xclip(1), xsel(2) or pbcopy/pbpaste(3) for all clipboard data manipulation steps
waitbit='0.3' # [fraction of] seconds to wait after pasting (prevents pasting/script interruption)

# yad selection dialog height. default values are optimal for mint cinnamon, adjust per your needs
peritem='23'
minimum='84'

yparent=('red' 'white') # yad foreground and background colors in "/.." items (navigate to parent)
yfolder=('green' 'white') # yad foreground and background colors used for the subdirectory entries
yfnames=('blue' 'white') # yad foreground and background colors used for all the filename entries.

belight='1' # use dmenu (a simpler and lightweight selector) on file/directories selection dialogs
lighter='1' # use dmenu to process all dialogs (including front-matter forms): kill yad dependency
bottoms='1' # display dmenu at bottom of screen (disable to display at top, can't be more obvious)
vertlis='30' # display dmenu items in a vertical list, with X lines. set 0 to display horizontally
preview='1' # display a "live preview" of front-matter bashdown variables bellow dmenu input field
# note: the preview lines are "filtered" as you type and will eventually disappear: once the input
# text do not match any of them! If it is a problem (you often ends up selecting an existing item)
# you can add a field 'preview:false' to disable field preview for a particular file. the same way
# you can add a field 'preview:true' to enable field it for a particular file if globally disabled

dmenunf='white' # dmenu foregound color
dmenunb='blue' # dmenu background color
dmenusf='blue' # selected item foregound
dmenusb='white' # selected item background
#RGB, #RRGGBB, and X color names are supported

maxsize='3' # display only files whose's size is up to X MBs
showall='0' # show hidden directories and files (be careful)
breakit='0' # show parent directories (be EVEN MORE careful)
bashing='1' # enforce executable files (+x) to run with bash
timeout='10' # the timeout for each directory/file selection
# the timeout is valid only for 'yad' file selection dialogs

clipboardterminal='clipboard' # this clipboard/X-area is used when pasting data to terminal window
clipboarddefault='clipboard' # and this one for the other windows (and when 'focusit' is disabled)
# accepted values: 'primary', 'secondary', 'clipboard' where primary and secondary are the X areas
# X 'primary' area: is used by most Linux distributions to save the text you highlight using mouse
# 'clipboard' is the same place where data is stored when you copy it with 'ctrl+c' to paste later
# any existing data found in the area/clipboard you selected is backed-up and restored afterwards!

pasteterminal='xdotool key ctrl+shift+v' # command to paste (when reXply is initiated on terminal)
pastedefault='xdotool key ctrl+v' # command to paste (when reXply is initiated on regular windows)
# 'xdotool click 2' # is often used in combination with terminal windows - to paste from X primary
# 'xdotool key ctrl+v' # primarily used in combination with regular windows - paste from clipboard
# 'xdotool key ctrl+shift+v' # recommended(*) alternative to paste on terminal if using clipboard!
# 'eval cat $tmpfile' # use to "paste" in OSX (pipe to pbcopy: rexply | pbcopy) and paste manually

# (*) IMPORTANT
# paste from primary with 'xdotool click 2' will paste to window under your MOUSE CURRENT POSITION
# while pasting from clipboard, reXply (tries to) paste at same window that were initially active!
# so I personally recommend always use clipboard and adjust only the paste command as necessary :)

# LAST NOTE
# all these settings can be overwritten by an additional configuration file at reply-data/.cfg/cfg

# THAT'S IT, STOP EDITING!










# INTERNAL SETUP
# set -x
run=$(basename ${BASH_SOURCE[0]});
realpath="${BASH_SOURCE[0]}";
while [[ -h "$realpath" ]]; do
	dir="$( cd -P "$( dirname "$realpath" )" && pwd )";
	realpath="$(readlink "$realpath")";
	[[ $realpath != /* ]] && realpath="$dir/$realpath";
done;
rexplydir="$(dirname ${realpath})";

logfile="$rexplydir/rexply-data/.log/log"
tmpfile="$rexplydir/rexply-data/.tmp/tmp"
replies="$rexplydir/rexply-data/repository"

configfile="$rexplydir/rexply.cfg"
[[ -f "$configfile" ]] && source $configfile

# @link http://github.com/coderofsalvation/bashdown
# @dependencies: sed cat
# @example: echo 'hi $USER it is $(date)' | bashdown
# fetches a document and interprets bashsyntax in string (bashdown) templates
# @param string - string with bash(down) syntax (usually surrounded by ' quotes instead of ")
bashdown() {
	txt="$(cat -)";
	lines="$(cat "$filename" | wc -l)" || yerror "unable to read file: $filename" || exit $?
	if [[ $lines == 1 ]]; then
		enter=""
	else
		enter="\n"
		header=$(cat "$filename" | grep -iEB100 -m2 '^---$' | grep -Ev '^---$')
		if [[ ! -z $header ]]; then
			yadform "${header}" || yerror "unable to process headers" || exit $?
			txt="$(awk "/^---$/{i++}i>=2{print}" "$filename" | tail -n +2)" || yerror "unable to strip headers from file: $filename" || exit $?
			unset IFS
		fi
	fi
	IFS=''
	txt=$(echo "$txt" | envsubst) || yerror "unable to perform variable substitutions" || exit $?
	echo "$txt" | while read line; do
		[[ "$line" =~ '$' ]] && line="$(eval "printf \"$( printf "%s" "$line" | sed 's/"/\\"/g')\"")"
		printf -- "$line""$enter"
	done || yerror "error bashing down the file contents" || exit $?
	unset IFS
	return 0
}

log() {
	local lexit=$?
	echo -e "$(date "+%F %T %Z (%:z)") $@" >>$logfile
	echo -e "$@" >&2
	return $lexit
}

yform() {
	yad --form --title="reXply" --width="580" --borders="20" --undecorated --on-top --center --skip-taskbar --image='accessories-text-editor' --quoted-output --separator="|" --button="gtk-ok" $@ 2>>$logfile
}

yadform() {
	IFS=$'\n'
	yadfields=()
	dmenufields=()
	types=('preview' 'editor' 'num' 'numeric' 'txt' 'textarea' 'field' 'var' 'entry' 'text')
	for fmfield in $@; do
		ytype=$(echo $fmfield | cut -d : -f 1 | tr '[:upper:]' '[:lower:]')
		for type in "${types[@]}"; do
			if [[ "$type" == "$ytype" ]]; then
				ydata=$(echo $fmfield | cut -d : -f 2-)
				ydata1=$(echo $ydata | cut -d : -f 1)
				ydata2=$(echo $ydata | cut -d : -f 2-)
				[[ "$ytype" == "editor" ]] && [[ "$ydata1" =~ (dmenu|light|cli|text|false|off|0) ]] && lighter="1"
				[[ "$ytype" == "editor" ]] && [[ "$ydata1" =~ (yad|full|gui|visual|true|on|1) ]] && lighter="0"
				[[ "$ytype" != "preview" ]] && { [[ "$lighter" != "1" ]] && yfieldlist+=("$ydata1") || dmfieldlist+=("$ydata1") ; }
				if [[ "$lighter" != "1" ]]; then
					case $ytype in
						preview|editor)
							;;
						num|numeric)
							yadfields+=("--field=$ydata1:NUM")
							getvalue="$(echo "$ydata2" | cut -d '#' -f 1)"
							[[ ! -z "$getvalue" ]] && yadfields+=("$getvalue") || yadfields+=("\${$ydata1}")
							;;
						txt|textarea)
							yadfields+=("--field=$ydata1:TXT")
							getvalue="$(echo "$ydata2" | cut -d '#' -f 1)"
							[[ ! -z "$getvalue" ]] && yadfields+=("$getvalue") || yadfields+=("\${$ydata1}")
							;;
						field|var|entry|text)
							yadfields+=("--field=$ydata1")
							getvalue="$(echo "$ydata2" | cut -d '#' -f 1)"
							[[ ! -z "$getvalue" ]] && yadfields+=("$getvalue") || yadfields+=("\${$ydata1}")
							;;
						*)
							;;
					esac
				else
					declare -A dmenufields
					case $ytype in
						editor)
							;;
						preview)
							[[ "$ydata1" =~ (true|on|yes|enable|enabled|1) ]] && preview="1"
							[[ "$ydata1" =~ (false|off|no|disable|disabled|0) ]] && preview="0"
							;;
						num|numeric)
							dmenufields[$ydata1]="$(echo "$ydata2" | cut -d '!' -f 1 | cut -d '#' -f 1)"
							;;
						field|var|entry|text|txt|textarea)
							dmenufields[$ydata1]="$(echo "$ydata2" | cut -d '#' -f 1)"
							;;
						*)
							;;
					esac
				fi
			fi
		done
	done
	if [[ "$lighter" != "1" ]]; then
		IFS='|'
		yform=($(yform ${yadfields[@]}))
		[[ $? == 0 ]] || { log "Notice: aborted" || backwindow || exit $? ; }
		IFS=$'\n'
		yfieldsstep=0
		for yfields in ${yfieldlist[@]}; do
			value=$(echo -e "${yform[$yfieldsstep]}")
			yfieldsstep=$((yfieldsstep+1))
			export ${yfields}="$value"
		done
	else
		for dfields in "${dmfieldlist[@]}"; do
			if [[ "$preview" == "1" ]]; then
				[[ "$vertlis" -lt ${#dmfieldlist[@]} ]] && vertlis=$((${#dmfieldlist[@]}+7))
				value=$( { echo -e "$( [[ ! -z "${dmenufields[$dfields]}" ]] && echo ${dmenufields[$dfields]} || echo "\${$dfields}" )\n" ; for dfieldsstep in ${dmfieldlist[@]}; do [[ "$dfields" == $dfieldsstep ]] && echo -en ">>> "; echo "[ $dfieldsstep ] => ${dmenufields[$dfieldsstep]}" ; done ; } | dmenu -nf $dmenunf -nb $dmenunb -sf $dmenusf -sb $dmenusb -l $vertlis $( [[ "$bottoms" != "0" ]] && echo "-b" ) -p "reXply" )
			else
				value=$( { [[ ! -z "${dmenufields[$dfields]}" ]] && echo ${dmenufields[$dfields]} || echo "\${$dfields}" ; } | dmenu -nf $dmenunf -nb $dmenunb -sf $dmenusf -sb $dmenusb -l $vertlis $( [[ "$bottoms" != "0" ]] && echo "-b" ) -p "reXply [ $dfields ]:" )
			fi
			[[ ! -z "$value" ]] && dmenufields[$dfields]=$value && export ${dfields}=$value || log "Error: aborted" || exit $?
		done
	fi
	unset IFS
}

yerror() {
	local yexit=$?
	log "Error: $@"
	if [[ "$lighter" != "1" ]]; then
		yad --image "dialog-error" --width="180" --title="reXply failed" --text="Error: $@"
	else
		echo -e "\nError: $@\n\n" | dmenu -b -nf white -nb red -sf white -sb red -l 10 -p "reXply"
	fi
	backwindow
	return $yexit
}

yask() {
	if [[ "$lighter" != "1" ]]; then
		yad --question --title="reXply question" --text="$1"
	else
		answer=""
		while [[ "$answer" != "(Y)es" ]] && [[ "$answer" != "(N)o" ]]; do
			answer=$(echo -e "$1\n[1] Yes\n[0] No" | dmenu -b -nf white -nb darkgreen -sf darkgreen -sb white -l $vertlis -p "reXply")
		done
		[[ $answer =~ 1 ]] && return 0 || return 1
	fi
}

backwindow() {
	local bexit=$?
	[[ "$focusit" == "1" ]] && xdotool windowactivate --sync $window 2>>$logfile
	return $bexit
}

pasteit() {
	if [[ "$focusit" == "1" ]]; then
		proc=$(xdotool getwindowpid $window 2>>$logfile) || yerror "unable to obtain origin window pid (did the process terminate?)" || exit $?
		cmdline="$(cat /proc/$proc/cmdline | tr '[:upper:]' '[:lower:]')" || yerror "unable to obtain active window cmdline" || exit $?
		xdotool windowactivate --sync $window 2>>$logfile || yerror "unable to focus the desired window to paste" || exit $?
		if [[ "$cmdline" =~ (terminal|terminator|tilix|tmux|tilda|guake) ]]; then
			paste=$pasteterminal
			clipboard=$clipboardterminal
		else
			paste=$pastedefault
			clipboard=$clipboarddefault
		fi
	else
		paste=$pastedefault
		clipboard=$clipboarddefault
	fi
	if [[ "$cbackup" != "0" ]]; then
		[[ "$copycmd" == "1" ]] && getclipboard="xclip -selection $clipboard -o" || { [[ "$copycmd" == "2" ]] && getclipboard="xsel --$clipboard -o" || getclipboard="pbpaste" ; }
		originalclipboard=$($getclipboard) || { yask "unable to backup current (empty?) clipboard data. proceed?" && originalclipboard="" || log "Notice: aborted" || backwindow || exit $? ; }
	fi
	if [[ "$copytoc" ]]; then
		case $copycmd in
			'1') xclip -selection $clipboard -i $tmpfile ;;
			'2') xsel  --$clipboard -i $tmptile ;;
			'3') cat $tmpfile | pbcopy ;;
			*) yerror "invalid \$copycmd value (set 1 for xclip, 2 for xsel, 3 for pbcopy/pbpaste)" || exit 1 ;;
		esac
		[[ $? != 0 ]] && { yerror "unable to copy tmpfile $i to $clipboard" || exit $? ; }
	fi
	[[ "$pasteit" != "0" ]] && { $paste && sleep "${waitbit}s" || yerror "unable to paste data to pid $proc ($cmdline)" || exit $? ; }
	if [[ $restore != "0" ]]; then
		[[ "$copycmd" == "1" ]] && restoreclipboard="xclip -selection $clipboard" || { [[ "$copycmd" == "2" ]] && restoreclipboard="xsel --$clipboard" || restoreclipboard="pbcopy" ; }
		echo $originalclipboard | $restoreclipboard || yerror "unable to restore original clipboard data" || exit $?
	fi
}

init() {
	apps=()
	[[ "$bashing" != "0" ]] && bashing="bash"
	[[ "$lighter" == "1" ]] && belight="1"
	[[ "$belight" == "1" ]] && apps+=('dmenu')
	[[ "$lighter" != "1" ]] && apps+=('yad')
	[[ "$focusit" == "1" ]] && apps+=('xdotool')
	[[ "$cbackup" != "0" ]] || [[ "$restore" != "0" ]] && {
		[[ "$copycmd" == "1" ]] && apps+=('xclip')
		[[ "$copycmd" == "2" ]] && apps+=('xsel')
		[[ "$copycmd" == "3" ]] && apps+=('pbcopy' 'pbpaste')
	}
	if [[ "$deptest" != "0" ]]; then
		for app in ${apps[@]}; do
			which "${app}" &>/dev/null || {
				if [[ "$app" == "yad" ]]; then
					read -rep "install the required utility: '$app' ? [y/n] " -n 1 installapp
					if [[ "$installapp" =~ (y|Y) ]]; then
						sudo apt install $app
						[[ $? != 0 ]] && { echo "Error: dependency not met ($app)" >&2 ; exit 1 ; }
					else
						echo "Error: dependency not met ($app)" ; exit 1
					fi
				else
					sudo=$(which pkexec || which gksudo || which kdesudo)
					[[ ! -z $sudo ]] || log "Error: can't determine correct pkexec/gksudo/kdesudo equivalent, please install '$app' manually" || exit $?
					yask "install the required utility: '$app' ?"
					[[ $? == 0 ]] && $sudo apt install $app
					[[ $? != 0 ]] && { echo "Error: dependency not met ($app)" >&2 ; exit 1 ; }
				fi
			}
		done
	fi
	for dirs in "$replies" "$(dirname $tmpfile)" "$(dirname $logfile)"; do
		if [[ ! -d "$dirs" ]]; then
			mkdir -p "$dirs" || { echo "Error: unable to create directory: $dirs" >&2 ; exit 1 ; }
		fi
	done
	:>>$logfile || { echo "Error: logfile ($logfile) is not writable" ; exit 1 ; }
	:>$tmpfile || yerror "tmpfile ($tmpfile) is not writable" || exit $?
	[[ "$focusit" == "1" ]] && { window=$(xdotool getactivewindow 2>>$logfile) || yerror "unable to detect active window" || exit $? ; }
	return 0
}

run() {
	maxsize=$((maxsize+1))
	[[ ! -z "$1" ]] && { [[ "$1" == "/"* ]] && replies=$1 || replies=$replies/$1 ; }
	filename=$(selectfile $replies)
	[[ $? != 0 ]] && exit $?
	if [[ -f "$filename" ]]; then
		if [[ -x "$filename" ]]; then
			${bashing} "$filename" &> $tmpfile || yerror "unable to write $filename execution output to tmpfile: $tmpfile" || exit $?
		else
			content="$(cat "$filename" | bashdown)"
			[[ $? != 0 ]] && exit $?
			if [[ "${#content}" == 0 ]]; then
				printf "$filename" > $tmpfile || yerror "unable to write $filename contents to tmpfile: $tmpfile" || exit $?
			else
				printf "%s" "$content" > $tmpfile || yerror "unable to write 'bashdown' output of $filename to tmpfile: $tmpfile" || exit $?
			fi
		fi
		pasteit $tmpfile || yerror "unable to paste data" || exit $?
		[[ "$killtmp" == "1" ]] && { rm -f $tmpfile || yerror "unable to remove tmpfile: $tmpfile" || exit $? ; }
		exit 0
	fi
}

selectfile() {
	if [[ -f $1 ]] || [[ -h $1 ]]; then
		echo $1
	else
		IFS=$'\n'
		options=()
		[[ "$breakit" == "1" ]] && options+=("/..") && [[ "$belight" != "1" ]] && options+=(${yparent[@]})
		for subdirs in $(find -L $replies -mindepth 1 -maxdepth 1 -type d -readable | sed "s@$replies@@g" | sort -n); do
			[[ "$subdirs" != "/."* ]] || [[ "$showall" == "1" ]] && options+=("$subdirs") && [[ "$belight" != "1" ]] && options+=(${yfolder[@]})
		done
		for files in $(find -L $replies -mindepth 1 -maxdepth 1 ! -name \*.swp -size -${maxsize}M -type f -readable | sed "s@$replies\/@@g" | sort -n); do
			[[ "$files" != "."* ]] || [[ "$showall" == "1" ]] && options+=("$files") && [[ "$belight" != "1" ]] && options+=(${yfnames[@]})
		done
		if [[ "$belight" != "1" ]]; then
			height=$(awk -v items=${#options[@]} -v ih=$peritem -v mh=$minimum 'BEGIN{printf "%d", ((items/3)*ih)+mh}')
			[[ "$timeout" -gt "0" ]] && height=$((height+10))
			name=$(yad --list --title="reXply" --text="Select the folder/file" --column="Files" --column="@fore@" --column="@back@" --no-headers --width="300" --height="$height" --timeout="$timeout" --timeout-indicator="top" --search-column="1" --regex-search ${options[@]} 2>/dev/null)
		else
			name=$( for dirorfile in ${options[@]}; do echo -e "$dirorfile"; done | dmenu -nf $dmenunf -nb $dmenunb -sf $dmenusf -sb $dmenusb $( [[ "$bottoms" != "0" ]] && echo "-b" ) -l $vertlis -i -p "reXply" )
		fi
		case $? in
			0) ;;
			1) log "Notice: aborted by user" || backwindow || exit $? ;;
			70) yerror "timeout" || exit $? ;;
			252) log "Notice: aborted by user" || backwindow || exit $? ;;
			*) log "Unknow error: dmenu returned status code $?" || backwindow || exit $? ;;
		esac
		name=$(echo $name | sed 's,|$,,')
		if [[ "$name" == "/.." ]]; then
			replies=$(dirname $replies)
			selectfile $replies || yerror "unable to navigate to parent directory: $replies" || exit $?
			return 0
		fi
		if [[ -d "$replies/$name" ]]; then
			replies=$replies$name
			selectfile $replies || yerror "unable to navigate to subdirectory: $replies" || exit $?
			return 0
		else
			if [[ -f $1/$name ]]; then
				echo $1/$name
			else
				yerror "invalid directory/file: $1/$name" || exit $?
			fi
		fi
		unset IFS
	fi
}

showhelp() {
	echo "
	reXply - A handy tool to copy/paste replies and scripts from a 'repository', with advanced 'headers' system, inline substitutions, bashdown, bash script processing - also used as a 'launcher' to other scripts/executables!

	https://github.com/renatofrota/rexply

	Parameters:

	-a X
		show All files (include hidden directories/files)
		directories/files starting with a dot (like .dir or .file) will be displayed
		0 to disable, 1 to enable
		current default: $showall

	-b X
		Backup clipboard data
		0 to disable, 1 to enable
		current default: $breakit

	-B X
		[potentially] Break it
		Allow browsing (and running scripts/templates on) parent directories (be careful!)
		0 to disable, 1 to enable
		current default: $breakit

	-m XX
		Max size
		maximum file size to display (in megabytes)
		integer value (1, 5, 10, ...)
		current default: $maxsize

	-d X
		check Dependencies
		0 to disable, 1 to enable
		current default: $deptest

	-p X
		Paste the reply
		0 to disable, 1 to enable
		note: implies -r 0 (do not Restore original clipboard)
		current default: $pasteit

	-r X
		Restore original clipboard data after reply is processed/pasted
		0 to disable, 1 to enable
		current default: $restore

	-k X
		Kill the tmp file (i.e.: delete it) after reply is processed/pasted
		0 to disable, 1 to enable
		current default: $killtmp

	-f X
		Focus the originally active window before pasting (prevents unwanted pastes to 'keep-on-top' windows)
		0 to disable, 1 to enable
		current default: $focusit

	-w X.X
		Wait time (in seconds) after pasting (prevent pasting interruption)
		integer/float (0.1, 0.5, 1, ...)
		current default: $waitbit

	-l X
		be Light interface (use 'dmenu' instead fancy 'yad' dialogs on file selections)
		0 to disable, 1 to enable
		current default: $belight

	-L X
		Lighter (use 'dmenu' for all dialogs, including front-matter forms)
		0 to disable, 1 to enable
		note: implies -l 1 (be Light)
		current default: $lighter

	-b X
		place selection menu at Bottom of screen menu
		0 to disable, 1 to enable
		note: needs -l 1 (Lighter) to take effect
		current default: $bottoms

	-V X
		Vertical listing
		0 to disable, 1 to enable
		note: needs -l 1 (Lighter) to take effect
		current default: $vertlis

	-t XX
		Timeout in seconds
		integer value, 0 to disable
		note: needs -l 0, -s 0, to take effect
		current default: $timeout

	-R <path> | <file>
		Repository path - or a direct file to process/run
		set a custom path from where to load the replies/scripts

		it can be an absolute path (starting with /)
		it can be a relative path (relative to current default repository)
		it can be an absolute/relative path to a file to be processed/run

		current default: $replies

	-v
		Show version number

	-c
		Show changelog and versio notes

	-h
		Show this help message
"
}

vversion() {
	echo "reXply v0.0.3 - https://github.com/renatofrota/rexply"
}

vchanges() {
	echo "
	reXply - A handy tool to copy/paste replies and scripts from a 'repository', with advanced 'headers' system, inline substitutions, bashdown, bash script processing - also used as a 'launcher' to other scripts/executables!

	https://github.com/renatofrota/rexply

	v0.0.3 - 2017-09-18
		[+] added 'editor' front-matter variable
		[*] renamed some front-matter variables for clarity
		[*] removed 'Cancel' button from yad form (front-matter inputs) to prevent unintentional closure (use Esc key)
		[*] minor bugfixes

	v0.0.2 - 2017-09-18
		[+] isolated 'cbackup' 'copytoc' 'pasteit' 'restore' as individual settings/steps
		[+] new 'copycmd' variable to select from xclip, xsel or pbcopy/pbpaste
		[+] new yes/no layout for 'dmenu' dialogs
		[+] new 'preview' front-matter variable
		[*] improved front-matter processing
		[*] changed a few parameter letters
		[*] vertical dmenu improvements
		[*] refactored a few functions
		[*] fixed logic in some tests

	v0.0.1 - 2017-09-17
		[+] initial release
"
}

while getopts "a:b:B:m:d:p:r:k:f:w:l:L:b:V:t:R:vch" opt; do
	case $opt in
		a) showall="$OPTARG" ;;
		b) cbackup="$OPTARG" ;;
		B) breakit="$OPTARG" ;;
		m) maxsize="$OPTARG" ;;
		d) deptest="$OPTARG" ;;
		p) pasteit="$OPTARG" ;;
		r) restore="$OPTARG" ;;
		k) killtmp="$OPTARG" ;;
		f) focusit="$OPTARG" ;;
		w) waitbit="$OPTARG" ;;
		l) belight="$OPTARG" ;;
		L) lighter="$OPTARG" ;;
		b) bottoms="$OPTARG" ;;
		V) vertlis="$OPTARG" ;;
		t) timeout="$OPTARG" ;;
		R) replies="$OPTARG" ;;
		v) vversion ; exit 0 ;;
		c) vchanges ; exit 0 ;;
		h) showhelp ; exit 0 ;;
		*) showhelp ; exit 1 ;;
	esac
done
shift $((OPTIND-1));

init && run $replies
exit 1