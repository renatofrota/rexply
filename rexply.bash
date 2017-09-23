#!/bin/bash
# reXply
version="0.0.8c"
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
[[ "$OSTYPE" == "darwin" ]] && pasteit='0' # this disables clipboard pasting in OSX automatically!
restore='1' # restore original clipboard data - disabling this you can paste data many other times
deltemp='1' # kill the tmpfile after pasting. disable it if you want to [re]use the processed data
copycmd='1' # use xclip(1), xsel(2) or pbcopy/pbpaste(3) for all clipboard data manipulation steps
[[ "$OSTYPE" == "darwin" ]] && copycmd='3' # this is to make pbcopy default for OSX automatically!
waitbit='0.3' # [fraction of] seconds to wait after pasting (prevents pasting/script interruption)

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

# yad selection dialog height. default values are optimal for mint cinnamon, adjust per your needs
peritem='23'
minimum='84'

# foreground & background colors for yad list items (parent dir, subdirs, normal and hidden files)
yparent=('red' 'white')
yfolder=('blue' 'white')
ycnfdir=('lightgray' 'white')
yfnames=('green' 'white')
yhidden=('gray' 'white')

yadfile='0' # use yad to process file/directory selection - disable to use dmenu instead (lighter)
yadform='0' # use yad to process form filling dialogs - when templates have front-matter variables

maxsize='3' # file selection will only show files up to X MB
# you can still pass a bigger file via -R or 1st non-opt arg
showall='0' # show hidden directories and files (be careful)
listord=('e' 'p' 'd' 'f' 'c' 'h') # choose the display order
# empty, parent, subdir, file, confdir, hidden (e/p/d/f/c/h)
execute='1' # if enabled files with +x permission are called
# directly, otherwise, are called through bash (bash <file>)
checkpt='1' # use '@' to mark the end of a template file and
# strip it after processing (or blank lines will be removed)
literal="2" # treat templates as literal commands by default
# if template has a front-matter it's disabled automatically
# '2' is a special case: consider only one-liners as literal
runeval="1" # substitute environment vars using eval command
# if disabled envsubst is used (+secure, but strip newlines)
# if template has a front-matter it is enabled automatically
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
# 'eval cat $1' # "paste" to stdout without xdotool (or pass '-p 0' and data will be in clipboard)

# (*) IMPORTANT
# paste from primary with 'xdotool click 2' will paste to window under your MOUSE CURRENT POSITION
# while pasting from clipboard, reXply (tries to) paste at same window that were initially active!
# so I personally recommend always use clipboard and adjust only the paste command as necessary :)

# LAST NOTE
# all these settings can be overwritten by an additional configuration file at reply-data/.cfg/cfg

# THAT'S IT, STOP EDITING!













# INTERNAL SETUP
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
	if [[ $lines -le 1 ]]; then
		enter=""
		[[ "$literal" == "2" ]] && literal="1"
	else
		enter="\n"
		header=$(cat "$filename" | grep -iEB100 -m2 '^---$' | grep -Ev '^---$')
		if [[ ! -z $header ]]; then
			literal="0"
			runeval="1"
			yadform "${header}" || yerror "unable to process headers" || exit $?
			txt="$(awk "/^---$/{i++}i>=2{print}" "$filename" | tail -n +2)" || yerror "unable to strip headers from file: $filename" || exit $?
		fi
	fi
	ifs "e"
	[[ "$literal" == "1" ]] && enter="" || { [[ "$runeval" == "0" ]] && { txt=$(echo "$txt" | envsubst) || yerror "unable to perform variable substitutions" || exit $? ; } }
	if [[ "$literal" != '1' ]] && [[ "$runeval" != "0" ]]; then
		echo "$txt" | sed 's/\\/\\\\/g' | while read line; do
			[[ "$line" =~ '$' ]] && line="$(eval "printf -- \"$( printf "%s" "$line" | sed 's/"/\\"/g')\"")"
			printf -- "$line$enter"
		done || yerror "unable to process parsed data with eval" || exit $?
	else
		echo "$txt" | sed 's/\\/\\\\/g' | while read line; do
			[[ "$line" =~ '$' ]] && line="$(printf -- "%s" "$line")"
			printf -- "%s" "$line$enter"
		done || yerror "unable to print out literal template" || exit $?
	fi
	ifs "r"
	return 0
}

log() {
	local lexit=$?
	echo -e "$(date "+%F %T %Z (%:z)") $@" >>$logfile
	echo -e "$@" >&2
	return $lexit
}

yform() {
	yad --form --title="reXply" --width="580" --borders="20" --undecorated --on-top --center --skip-taskbar --image='accessories-text-editor' --separator="|" --button="gtk-ok" $@ 2>>$logfile
}

yadform() {
	ifs "n"
	yadfields=()
	dmenufields=()
	types=('literal' 'runeval' 'preview' 'editor' 'num' 'numeric' 'txt' 'textarea' 'field' 'var' 'entry' 'text')
	for fmfield in $@; do
		ytype=$(echo $fmfield | cut -d : -f 1 | tr '[:upper:]' '[:lower:]')
		for type in "${types[@]}"; do
			if [[ "$type" == "$ytype" ]]; then
				ydata=$(echo $fmfield | cut -d : -f 2-)
				ydata1=$(echo $ydata | cut -d : -f 1)
				ydata2=$(echo $ydata | cut -d : -f 2-)
				[[ "$ytype" == "editor" ]] && [[ "$ydata1" =~ (yad|full|gui|visual|true|on|yes|enable|1) ]] && yadform="1"
				[[ "$ytype" == "editor" ]] && [[ "$ydata1" =~ (dmenu|light|cli|text|false|off|no|disable|0) ]] && yadform="0"
				[[ "$ytype" == "literal" ]] && [[ "$ydata1" =~ (true|on|yes|1) ]] && literal="1"
				[[ "$ytype" == "literal" ]] && [[ "$ydata1" =~ (false|off|no|0) ]] && literal="0"
				[[ "$ytype" == "runeval" ]] && [[ "$ydata1" =~ (true|on|yes|1) ]] && runeval="1"
				[[ "$ytype" == "runeval" ]] && [[ "$ydata1" =~ (false|off|no|0) ]] && runeval="0"
				[[ "$ytype" != "preview" ]] && [[ $ytype != "editor" ]] && [[ $ytype != "literal" ]] && [[ $ytype != "runeval" ]] && {
					[[ "$yadform" == "1" ]] && yfieldlist+=("$ydata1") || dmfieldlist+=("$ydata1")
				}
				if [[ "$yadform" == "1" ]]; then
					case $ytype in
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
						preview)
							[[ "$ydata1" =~ (true|on|yes|enable|1) ]] && preview="1"
							[[ "$ydata1" =~ (false|off|no|disable|0) ]] && preview="0"
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
	if [[ "$yadform" == "1" ]]; then
		ifs "p"
		yform=($(yform ${yadfields[@]}))
		[[ $? == 0 ]] || { log "Notice: aborted" || backwindow || exit $? ; }
		ifs "n"
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
				value=$( { echo -e "$( [[ ! -z "${dmenufields[$dfields]}" ]] && echo ${dmenufields[$dfields]} || echo "\${$dfields}" )\n" ; for dfieldsstep in ${dmfieldlist[@]}; do [[ "$dfields" == $dfieldsstep ]] && echo -en ">>> "; echo "[ $dfieldsstep ] => ${dmenufields[$dfieldsstep]}" ; done ; } | dmenu -nf $dmenunf -nb $dmenunb -sf $dmenusf -sb $dmenusb -l $vertlis $( [[ "$bottoms" != "0" ]] && echo "-b" ) -p "reXply [ $dfields ]" )
			else
				value=$( { [[ ! -z "${dmenufields[$dfields]}" ]] && echo ${dmenufields[$dfields]} || echo "\${$dfields}" ; } | dmenu -nf $dmenunf -nb $dmenunb -sf $dmenusf -sb $dmenusb -l $vertlis $( [[ "$bottoms" != "0" ]] && echo "-b" ) -p "reXply [ $dfields ]" )
			fi
			[[ ! -z "$value" ]] && dmenufields[$dfields]="$value" && export ${dfields}="$value" || log "Error: aborted" || exit $?
		done
	fi
	ifs "r"
}

yerror() {
	local yexit=$?
	log "Error: $@"
	if [[ "$yadform" == "1" ]]; then
		yad --image "dialog-error" --width="180" --title="reXply failed" --text="Error: $@"
	else
		echo -e "\nError: $@\n\n" | dmenu -b -nf white -nb red -sf white -sb red -l 10 -p "reXply"
	fi
	backwindow
	return $yexit
}

yask() {
	if [[ "$yadform" == "1" ]]; then
		yad --question --title="reXply question" --text="$1"
	else
		answer=""
		while [[ "$answer" != "[1] Yes" ]] && [[ "$answer" != "[0] No" ]]; do
			answer=$(echo -e "$1\n[1] Yes\n[0] No" | dmenu -b -nf white -nb darkgreen -sf darkgreen -sb white -l $vertlis -i -p "reXply")
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
	txt="$(cat -)"
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
		[[ "$PPID" == "1" ]] && { paste=$pastedefault ; log "PPID: $PPID (default)" ; } || { paste=$pasteterminal ; log "PPID: $PPID (terminal)" ; }
		clipboard=$clipboarddefault
	fi
	if [[ "$cbackup" != "0" ]]; then
		[[ "$copycmd" == "1" ]] && getclipboard="xclip -selection $clipboard -o" || { [[ "$copycmd" == "2" ]] && getclipboard="xsel --$clipboard -o" || getclipboard="pbpaste" ; }
		originalclipboard=$($getclipboard) || { yask "unable to backup current (empty?) clipboard data. proceed?" && originalclipboard="" || log "Notice: aborted" || backwindow || exit $? ; }
	fi
	if [[ "$copytoc" ]]; then
		case $copycmd in
			'1') xclip -selection $clipboard -i $1 ;;
			'2') xsel  --$clipboard -i $1 ;;
			'3') cat $1 | pbcopy ;;
			*) yerror "invalid \$copycmd value (set 1 for xclip, 2 for xsel, 3 for pbcopy/pbpaste)" || exit 1 ;;
		esac
		[[ $? != 0 ]] && { yerror "unable to copy tmpfile $i to $clipboard" || exit $? ; }
	fi
	[[ "$pasteit" != "0" ]] && { ${paste} && sleep "${waitbit}s" || yerror "unable to paste data to pid $proc ($cmdline)" || exit $? ; }
	if [[ $restore != "0" ]]; then
		[[ "$copycmd" == "1" ]] && restoreclipboard="xclip -selection $clipboard" || { [[ "$copycmd" == "2" ]] && restoreclipboard="xsel --$clipboard" || restoreclipboard="pbcopy" ; }
		echo $originalclipboard | $restoreclipboard || yerror "unable to restore original clipboard data" || exit $?
	fi
}

init() {
	apps=()
	bashing=""
	[[ "$execute" != "0" ]] && bashing="bash"
	[[ "$yadfile" == "1" ]] || [[ "$yadform" == "1" ]] && apps+=('yad')
	[[ "$yadfile" != "1" ]] || [[ "$yadform" != "1" ]] && apps+=('dmenu')
	[[ "$copytoc" != "0" ]] && [[ "$pasteit" != "1" ]] && restore="0"
	[[ "$cbackup" != "1" ]] && restore="0"
	[[ "$pasteit" != "1" ]] && focusit="0"
	{ [[ "$pasteterminal" =~ xdotool ]] && [[ "$PPID" != "1" ]] ; } || {
		[[ "$pastedefault" =~ xdotool ]] && [[ "$PPID" == "1" ]] ; } || {
			[[ "$focusit" == "1" ]] ; } && { apps+=('xdotool') ; }
	[[ "$cbackup" != "0" ]] || [[ "$copytoc" != "0" ]] && {
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
		if [[ ! -d "$dirs" ]] && [[ ! -f "$dirs" ]]; then
			mkdir -p "$dirs" || { echo "Error: unable to create directory: $dirs" >&2 ; exit 1 ; }
		fi
	done
	:>>$logfile || { echo "Error: logfile ($logfile) is not writable" ; exit 1 ; }
	:>$tmpfile || yerror "tmpfile ($tmpfile) is not writable" || exit $?
	[[ "$focusit" == "1" ]] && { window=$(xdotool getactivewindow 2>>$logfile) || yerror "unable to detect active window" || exit $? ; }
	maxsize=$((maxsize+1))
	return 0
}

replies() {
	[[ ! -z "$1" ]] && { [[ "$1" == "/"* ]] && replies=$1 || replies=$replies/$1 ; } || yerror="invalid custom path" || exit $?
}

run() {
	[[ ! -z "$1" ]] && replies "$1"
	filename=$(selectfile $replies)
	[[ $? != 0 ]] && exit $?
	if [[ -f "$filename" ]]; then
		if [[ -x "$filename" ]]; then
			${bashing} "$filename" &> $tmpfile || yerror "unable to write $filename execution output to tmpfile: $tmpfile" || exit $?
		else
			content="$(cat "$filename" | bashdown)"
			[[ $? != 0 ]] && { yerror "unable to save bashdown content into a shell var" || exit $? ; }
			if [[ "${#content}" == 0 ]]; then
				printf "$filename" > $tmpfile || yerror "unable to write $filename contents to tmpfile: $tmpfile" || exit $?
			else
				printf "%s" "$content" > $tmpfile || yerror "unable to write 'bashdown' output of $filename to tmpfile: $tmpfile" || exit $?
			fi
		fi
		[[ "$checkpt" == "1" ]] && checkpt $tmpfile || yerror "unable to remove the placeholder char at end of $tmpfile" || exit $?
		cat $tmpfile | pasteit $tmpfile || yerror "unable to paste data" || exit $?
		[[ "$deltemp" == "1" ]] && { rm -f $tmpfile || yerror "unable to remove tmpfile: $tmpfile" || exit $? ; }
		exit 0
	fi
}

checkpt() {
	lastline="$(tail -1 $1)"
	while [[ "$lastline" == *"@" ]]; do
		truncate -s -1 $1 || yerror "failure on truncating $1 at it's last byte" || exit $?
		sleep "${waitbit}s"
		lastline="$(tail -1 $1)"
	done
}

e() {
	[[ "$yadfile" != "1" ]] && options+=(" ")
	return 0
}

p() {
	options+=("/..")
	[[ "$yadfile" == "1" ]] && options+=(${yparent[@]})
	return 0
}

d() {
	for subdirs in $(find -L $replies -mindepth 1 -maxdepth 1 ! -name .\* -type d -readable | sed "s@$replies@@g" | sort -n); do
		[[ "$subdirs" != "/."* ]] || [[ "$showall" == "1" ]] && options+=("$subdirs") && [[ "$yadfile" == "1" ]] && options+=(${yfolder[@]})
	done
	return 0
}

c() {
	for confdirs in $(find -L $replies -mindepth 1 -maxdepth 1 -name .\* -type d -readable | sed "s@$replies@@g" | sort -n); do
		[[ "$showall" == "1" ]] && options+=("$confdirs") && [[ "$yadfile" == "1" ]] && options+=(${ycnfdir[@]})
	done
	return 0
}

f() {
	for files in $(find -L $replies -mindepth 1 -maxdepth 1 ! -name \*.swp ! -name .\* -size -${maxsize}M -type f -readable | sed "s@$replies\/@@g" | sort -n); do
		[[ "$files" != "."* ]] || [[ "$showall" == "1" ]] && options+=("$files") && [[ "$yadfile" == "1" ]] && options+=(${yfnames[@]})
	done
	return 0
}

h() {
	for hiddenfiles in $(find -L $replies -mindepth 1 -maxdepth 1 ! -name \*.swp -name .\* -size -${maxsize}M -type f -readable | sed "s@$replies\/@@g" | sort -n); do
		[[ "$showall" == "1" ]] && options+=("$hiddenfiles") && [[ "$yadfile" == "1" ]] && options+=(${yhidden[@]})
	done
	return 0
}

selectfile() {
	[[ -f $1 ]] && echo $1 && return 0
	ifs "n"
	options=()
	tolistfunctions=('e' 'p' 'd' 'f' 'c' 'h')
	for tolist in ${listord[@]}; do
		for tolistfunction in ${tolistfunctions[@]}; do
			[[ "$tolist" == "$tolistfunction" ]] && { $tolist || yerror "unable to process list of files" || exit $? ; }
		done
	done
	if [[ "$yadfile" == "1" ]]; then
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
	if [[ "$name" == " " ]]; then
		selectfile $replies || yerror "unable to proceed with directory selection" || exit $?
		return 0
	fi
	if [[ "$name" == "/.." ]]; then
		replies=$(dirname $replies)
		selectfile $replies || yerror "unable to navigate to parent directory: $replies" || exit $?
		return 0
	fi
	if [[ -d "$replies/$name" ]]; then
		replies=$replies/$name
		selectfile $replies || yerror "unable to navigate to subdirectory: $replies" || exit $?
		return 0
	else
		if [[ -f "$replies/$name" ]]; then
			echo "$replies/$name"
		else
			yerror "invalid directory/file: $replies$name" || exit $?
		fi
	fi
	ifs "r"
}

pastepp() {
	pasteit='1'
	pastedefault="$1"
	pasteterminal="$1"
}

showhelp() {
	echo "
	reXply - A handy tool to copy/paste replies and scripts from a 'repository', with advanced 'headers' system, inline substitutions, bashdown, bash script processing - also used as a 'launcher' to other scripts/executables!

	https://github.com/renatofrota/rexply

	Parameters:

	-a X
		show All files (including hidden directories/files)
		directories/files starting with a dot (like .dir or .file) will be displayed
		0 to disable, 1 to enable
		current default: $showall

	-b X
		Backup clipboard data
		0 to disable, 1 to enable
		current default: $cbackup

	-B X
		place selection menu at Bottom of screen menu
		0 to disable, 1 to enable
		note: needs \$yadfile='0' or -l 1 to take effect
		current default: $bottoms

	-c X
		copy processed data to clipboard
		0 to disable, 1 to enable
		current default: $copytoc

	-C
		view full Changelog

	-d X
		Delete the tmp file (i.e.: delete it) after reply is processed/pasted
		0 to disable, 1 to enable
		current default: $deltemp

	-D X
		check Dependencies
		0 to disable, 1 to enable
		current default: $deptest

	-e X
		vErtical listing
		0 to disable, 1 to enable
		note: needs \$yadfile='1' or -l 1 to take effect
		current default: $vertlis

	-E X
		run eval
		process templates using 'eval'. if disabled, only 'envsubst' is used
		0 to disable, 1 to enable
		note: envsubst won't run subshells (more secure) but you lose linebreaks
		current default: $runeval

	-f X
		Focus the originally active window before pasting
		(prevents unwanted pastes to 'always-on-top' windows)
		0 to disable, 1 to enable
		current default: $focusit

	-h
		Show this help message

	-k X
		Remove cheKpoints ('@' at the end of template files)
		0 to disable, 1 to enable
		current default: $checkpt

	-l X
		treat template as a Literal command
		0 to disable, 1 to enable, 2 enable on one-liners
		current default: $literal

	-m XX
		Maximum file size to display (in megabytes)
		integer value (1, 5, 10, ...)
		current default: $maxsize

	-p X
		Paste the reply
		0 to disable, 1 to enable
		note: implies -r 0 (do not Restore original clipboard)
		current default: $pasteit

	-P 'command \$1'
		set the Paste command (for both terminal and regular windows)
		yhe variable '\$1' represents the tmpfile holding the processed data
		you will probably want to use single quotes and parse it using 'eval'
		note: implies -p 1 (enable pasting)
		example: -P 'eval cat \$1'

	-r X
		Restore original clipboard data after reply is processed/pasted
		0 to disable, 1 to enable
		current default: $restore

	-R <path> | <file>
		Repository path (or a direct file to process/run)
		set a custom path from where to load the replies/scripts

		it can be an absolute path (starting with /)
		it can be a relative path (relative to current default repository)
		it can be an absolute/relative path to a file to be processed/run

		tip: you can also pass the repository/file path as the first non-option argument

		current default: $replies

	-t XX
		Timeout in seconds
		integer value, 0 to disable
		note: needs -l 0, -s 0, to take effect
		current default: $timeout

	-v
		Show version number

	-V
		Show release notes

	-w X.X
		Wait time (in seconds) after pasting (prevent pasting interruption)
		integer/float (0.1, 0.5, 1, ...)
		current default: $waitbit

	-x
		set x bit on process execution for debug

	-X X
		eXecute file directly
		if the file is executable and this is enabled, execute the file directly instead calling 'bash <file>'
		0 to disable, 1 to enable
		current default: $execute

	-y X
		Yad file selection interface
		Use 'yad' fancy dialogs for file selections instead 'dmenu'
		0 to disable, 1 to enable
		current default: $yadfile

	-Y X
		Yad Forms
		Use 'yad' forms to insert template's front-matter variables
		0 to disable, 1 to enable
		current default: $yadform
"
}

vversion() {
	echo "reXply $version - https://github.com/renatofrota/rexply"
}

vrelease() {
	vversion
	echo -e "\nRelease notes:\n"
	vchanges | awk "/^\tv$version/{i++}i>=1{print}" | awk "/^\tv/{i++}i<2{print}"
}

vchanges() {
	echo "
	reXply - A handy tool to copy/paste replies and scripts from a 'repository', with advanced 'headers' system, inline substitutions, bashdown, bash script processing - also used as a 'launcher' to other scripts/executables!

	https://github.com/renatofrota/rexply

	v0.0.8c - 2017-09-23
		[+] config/front-matter var: 'literal' (treat template as a commnd line, do not substitute or run var or subshell)
		[+] added a special value to \$literal: 2 (consider only one-liners as literal by default)
		[+] config/front-matter var: 'runeval' (use eval to substitute variables and run subshells)
		[+] treat hidden subfolders (\"conf folders\") and hidden files differently (than regular folders and files)
		[+] added \$execute config (-X parameter) to control if files are executed directly or through bash (former \$bashing config)

	v0.0.7 - 2017-09-20
		[*] -P now implies -p

	v0.0.6 - 2017-09-20
		[+] added -P parameter (to set paste command for both terminal and regular windows)
		[*] pasting is disabled and copycmd is set 3 (pbcopy/pbpaste) automatically on OSX

	v0.0.5 - 2017-09-20
		[*] improved logics (e.g.: skip clipboard restore when skip pasting and data is on clipboard)
		[*] moved example scripts to a single folder to keep repository clean
		[+] new method/options to list directories and files (\$listord)
		[*] PID detection when \$focusit='0' (or -f 0)
		[*] better \$IFS management

	v0.0.4 - 2017-09-18
		[*] fixed a problem with 'editor' not taking effect or affecting other fields under some circumstances

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

while getopts "a:b:c:Cd:D:e:E:f:hk:l:m:p:P:r:R:t:vVw:xX:y:Y:" opt; do
	case $opt in
		a) showall="$OPTARG" ;;
		b) cbackup="$OPTARG" ;;
		B) bottoms="$OPTARG" ;;
		c) copytoc="$OPTARG" ;;
		C) vchanges ; exit 0 ;;
		d) deltemp="$OPTARG" ;;
		D) deptest="$OPTARG" ;;
		e) vertlis="$OPTARG" ;;
		E) runeval="$OPTARG" ;;
		f) focusit="$OPTARG" ;;
		h) showhelp ; exit 0 ;;
		k) checkpt="$OPTARG" ;;
		l) literal="$OPTARG" ;;
		m) maxsize="$OPTARG" ;;
		p) pasteit="$OPTARG" ;;
		P) pastepp "$OPTARG" ;;
		r) restore="$OPTARG" ;;
		R) replies "$OPTARG" ;;
		t) timeout="$OPTARG" ;;
		v) vversion ; exit 0 ;;
		V) vrelease ; exit 0 ;;
		w) waitbit="$OPTARG" ;;
		x) set -x ;;
		X) execute="$OPTARG" ;;
		y) yadfile="$OPTARG" ;;
		Y) yadform="$OPTARG" ;;
		*) showhelp ; exit 1 ;;
	esac
done
shift $((OPTIND-1));

IFS_OLD=$IFS

ifs() {
	[[ "$1" == "e" ]] && IFS='' && return 0
	[[ "$1" == "n" ]] && IFS=$'\n' && return 0
	[[ "$1" == "p" ]] && IFS=$'|' && return 0
	[[ "$1" == "r" ]] && IFS=$OLD_IFS && return 0
}

init && run $1
exit 1
