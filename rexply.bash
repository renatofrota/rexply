#!/bin/bash
# reXply
version="0.1.8"
revision="a"
# version number not updated on minor changes
# @link https://github.com/renatofrota/rexply

# INSTALLATION
# clone repo, symlink the binary at a directory in your $PATH

# EXAMPLE
# cd ~/ ; git clone https://github.com/renatofrota/rexply.git
# ln -s ~/rexply/rexply.bash $(echo $PATH|cut -d: -f1)/rexply

# ENVIRONMENT CONFIGURATION
# set keyboard shortcuts to
# "rexply" init reXply from it's default repository ./replies
# "rexply -R subdir" init directly from that ./replies/subdir
# "rexply -R subdir/or/file" run or process the file directly
# "rexply -R /absolute/dir/or/file" (with a forwarding slash)

# GENERAL SETTINGS

cbackup='1' # backup current clipboard data before doing anything so it can be restored afterwards
copytoc='1' # copy processed data (importing template, processing frontmatter, etc..) to clipboard
# before you ask: one may be interested in using reXply just to process the data then use $tmpfile
focusit='1' # focus the window before pasting - prevents unwanted pastes to always-on-top windows!
# note: by disabling 'focusit' option the default clipboard and paste command will always be used!
# eliminates the xdotool dependency - useful in OSX - but you will need to paste the data manually
pasteit='1' # truly (and automatically) paste data after you select source file and it's processed
[[ "$OSTYPE" == "darwin" ]] && pasteit='0' # this disables clipboard pasting in OSX automatically!
restore='1' # restore original clipboard, otherwise you can paste output data other times manually
deltemp='1' # kill the tmpfile after pasting. disable it if you want to [re]use the processed data
copycmd='1' # use xclip(1), xsel(2) or pbcopy/pbpaste(3) for all clipboard data manipulation steps
[[ "$OSTYPE" == "darwin" ]] && copycmd='3' # this is to make pbcopy default for OSX automatically!
waitbit='0.3' # [fraction of] seconds to wait after pasting (prevents pasting/script interruption)
seepath='1' # see path of current directory during file selection. better set 0 for narrow screens 

# FILE SELECTION SETTINGS

maxsize='3' # file selection will only show files up to X MB
# you can still pass a bigger file via -R or 1st non-opt arg
showall='0' # show hidden directories and files (be careful)
listord=('e' 'f' 'h' 's' 'c' 'p') # list order (c,e,f,h,p,s)
# confdirs, empty line, files, hidden files, parent, subdirs

# EXECUTION SETTINGS

execute='1' # if enabled files with +x permission are called
# directly, otherwise, are called through bash (bash <file>)
checkpt='1' # use '@' to mark the end of a template file and
# strip it after processing (or blank lines will be removed)
runeval="0" # substitute environment vars using eval command
# when disabled envsubst is used (more secure, no subshells)
# you can enable eval for a specific template with runeval:1
bashcmd="0" # pass template parsing output to bash (bash -c)

# UTILITIES SETTINGS

yadfile='1' # use yad to process file/directory selection - disable to use dmenu instead (lighter)
yadform='1' # use yad to process forms (when template have front-matter vars or dynamic questions)
yademsg='1' # use yad to display error messages in dialogs (1 to enable, 0 disables and use dmenu)
yadicon='1' # display image on yad dialog (0, 1 or custom value). defaults to 'preferences-system'
# you can pass another gtk-icon name or set your own custom icon (preferably use an absolute path)

[[ "$OSTYPE" == "darwin" ]] && yadfile='0' && yadform='0' && yademsg='0'
# dmenu is apparently easier to install in OSX than yad (I have no OSX!)

# CLIPBOARD SETTINGS

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

# (*)IMPORTANT
# paste from primary with 'xdotool click 2' will paste to window under your MOUSE CURRENT POSITION
# while pasting from clipboard, reXply (tries to) paste to the same window that was active on init
# so I personally recommend always use clipboard and adjust only the paste command as necessary :)

# DMENU SETTINGS

bottoms='0' # dmenu is displayed at top of screen by default. set 1 to display dmenu at the bottom
vertlis='10' # display dmenu items in a vertical list, with X lines. set 0 to display horizontally
preview='1' # display a "live preview" of front-matter fields [to be] processed bellow dmenu items
# note: the preview lines are "filtered" as you type and will eventually disappear: once the input
# text do not match any of them! If it is a problem (you often ends up selecting an existing item)
# you can add a field 'preview:false' to disable field preview for a particular file. the same way
# you can add a field 'preview:true' to enable field it for a particular file if globally disabled
# or just get used to hit shift+enter to submit what you have typed in, ignoring any matching line
seetips='1' # display tips about dmenu shortcuts below input fields (when processing front-matter)
toupper='1' # display preview/tips using only uppercase letters (prevents matching your own input)

# DMENU COLORS

dmenucc='1' # use custom colors for dmenu
#RGB, #RRGGBB, and X color names are supported
dmenunf='#fff' # dmenu normal foreground color
dmenunb='#222' # dmenu normal background color
dmenusf='#0f0' # selected item foreground color
dmenusb='#000' # selected item background color

# YAD SETTINGS

# default values are optimal for mint cinnamon
minimum='84' # yad selection dialog minimum height
peritem='23' # additional height each visible item
timeout='30' # timeout for each file/dir selection

# YAD COLORS

# foreground & background colors for yad list items
# parent, subdirs, hidden dirs, files, hidden files
yparent=('red' 'white')
ysubdir=('blue' 'white')
ycnfdir=('lightgray' 'white')
yfnames=('green' 'white')
yhidden=('gray' 'white')

# LAST NOTES

# 1.
# these settings may be overwritten by the configuration file rexply.cfg
# and in sequency by the file $HOME/.rexply/rexply.cfg in case it exists
# it's recommended you create that one - only it will survive updates :)

# 2.
# the default repository is ./replies subdir, under this script location
# if $HOME/.rexply/replies exists, it will be used instead automatically

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

logfile="$rexplydir/.log"
tmpfile="$rexplydir/.tmp"
replies="$rexplydir/replies"
configf="$rexplydir/rexply.cfg"

inarray() {
	local array="$1[@]"
	local seeking=$2
	local in=1
	for element in "${!array}"; do
		if [[ $element == $seeking ]]; then
			in=0
			break
		fi
	done
	return $in
}

to() {
	local input=$(cat -)
	case $1 in
		upper)
			if [[ $2 != "0" ]]; then
				echo "$(echo -en "$input" | tr '[:lower:]' '[:upper:]')"
			else
				echo "$(echo -en "$input")"
			fi
			;;
		lower)
			echo "$(echo -en "$input" | tr '[:upper:]' '[:lower:]')" ;;
	esac
	return 0
}

process() {
	txt="$(cat -)";
	literal="1"
	lines="$(cat "$1" | wc -l)" || yerror "unable to read file: $1" || exit $?
	fname=$1
	if [[ $lines -le 1 ]]; then
		enter=""
	else
		enter="\n"
	fi
	header=$(cat "$1" | grep -iEB100 -m2 '^---$' | grep -Ev '^---$')
	[[ ! -z "$header" ]] && { txt="$(awk "/^---$/{i++}i>=2{print}" "$1" | tail -n +2)" || yerror "unable to strip headers from file: $1" || exit $? ; }
	questions="0"
	declare -A questiontitles
	ifs "n"
	for questiontitle in $(echo "$txt" | grep -oE '\{\{\?[^\}]*\}\}' | sed -e 's,{{?\([^}]*\)}},\1,'); do
		if ( ! inarray questiontitles "$questiontitle" ); then
			header="$(echo -e "${header}\nentry:question_$questions!$questiontitle:")"
			questiontitles[$questions]="$questiontitle"
			questions=$((questions+1))
		fi
	done
	ifs "r"
	if [[ ! -z $header ]]; then
		rexply=()
		literal="0"
		yadform "${header}" || yerror "output of template processing is empty - process aborted or failed" || exit $?
	fi
	if [[ "$literal" != "1" ]]; then
		ifs "n"
		if [[ "$questions" != 0 ]]; then
			for questiontitle in ${!questiontitles[@]}; do
				txt=$(echo "$txt" | sed -e "s,{{?${questiontitles[$questiontitle]}}},\${rexply_question_${questiontitle}},")
			done
		fi
		ifs "r"
		for rfield in ${rexply[@]}; do
			txt=$(echo "$txt" | sed -e "s,\${$rfield},\${rexply_$rfield},g")
		done
		if [[ "$runeval" != "1" ]]; then
			txt=$(echo "$txt" | envsubst) || yerror "unable to perform variable substitutions" || exit $?
			echo "$txt" || yerror "unable to print out template" || exit $?
		else
			echo "$txt" | sed 's/\\/\\\\/g' | while read line; do
				[[ "$line" =~ '$' ]] && line="$(eval "printf -- \"$( printf "%s" "$line")\"")"
				printf -- "$line$enter"
			done || yerror "unable to process parsed data with eval" || exit $?
		fi
		if [[ "$bashcmd" == "1" ]]; then
			bash -c "${txt}" || yerror "command exited with error: '$txt' ($?)" || exit $?
			exit 1;
		fi
	else
		echo "$txt" || yerror "unable to print out literal template" || exit $?
	fi
	return 0
}

log() {
	local lexit=$?
	echo -e "$(date "+%F %T %Z (%:z)") $@" >>$logfile
	echo -e "$@" >&2
	return $lexit
}

icons() {
	case $yadicon in
		0) ;;
		1) echo "--image=preferences-system" ;;
		*) echo "--image=$yadicon" ;;
	esac
	return 0
}

yform() {
	yad --on-top --center --form --title="$(basename $fname)" --width="580" --borders="20" $(icons) --separator="|" --button="gtk-ok" $@ 2>>$logfile
}

yadform() {
	ifs "n"
	yadfields=()
	yfieldlist=()
	dmfieldlist=()
	types=('keep' 'hidden' 'set' 'runeval' 'bashcmd' 'preview' 'editor' 'yadform' 'yadicon' 'num' 'numeric' 'txt' 'textarea' 'field' 'var' 'entry' 'text' 'combo' 'combobox' 'sel' 'select' 'selectbox')
	for fmfield in $@; do
		ytype=$(echo $fmfield | cut -d : -f 1 | to lower)
		for type in "${types[@]}"; do
			if [[ "$type" == "$ytype" ]]; then
				ydata=$(echo $fmfield | cut -d : -f 2-)
				ydata1=$(echo $ydata | cut -d : -f 1)
				ydata2=$(echo $ydata | cut -d : -f 2-)
				ydatat=$(echo $ydata1 | cut -d '!' -f 2-)
				ydata1=$(echo $ydata1 | cut -d '!' -f 1)
				[[ "$ytype" =~ (keep|hidden|set) ]] && rexply+=($ydata1) && export rexply_$ydata1="\$$ydata1"
				[[ "$ytype" =~ (editor|yadform) ]] && [[ "$ydata1" =~ (yad|full|gui|visual|true|on|yes|enable|1) ]] && yadform="1"
				[[ "$ytype" =~ (editor|yadform) ]] && [[ "$ydata1" =~ (dmenu|light|cli|text|false|off|no|disable|0) ]] && yadform="0"
				[[ "$ytype" == "runeval" ]] && [[ "$ydata1" =~ (true|on|yes|1) ]] && runeval="1"
				[[ "$ytype" == "runeval" ]] && [[ "$ydata1" =~ (false|off|no|0) ]] && runeval="0"
				[[ "$ytype" == "bashcmd" ]] && [[ "$ydata1" =~ (true|on|yes|1) ]] && bashcmd="1"
				[[ "$ytype" == "bashcmd" ]] && [[ "$ydata1" =~ (false|off|no|0) ]] && bashcmd="0"
				[[ "$ytype" == "yadicon" ]] && yadicon="$ydata1"
				[[ ! "$ytype" =~ (keep|hidden|set|preview|editor|yadform|runeval|bashcmd) ]] && {
					[[ "$yadform" == "1" ]] && yfieldlist+=("$ydata1") || dmfieldlist+=("$ydata1")
				}
				if [[ "$yadform" == "1" ]]; then
					case $ytype in
						field|var|entry|text)
							yadfields+=("--field=$ydatat")
							getvalue="$(echo "$ydata2" | cut -d '#' -f 1)"
							[[ ! -z "$getvalue" ]] && yadfields+=("$getvalue") || yadfields+=("")
							;;
						txt|textarea)
							yadfields+=("--field=$ydatat:TXT")
							getvalue="$(echo "$ydata2" | cut -d '#' -f 1)"
							[[ ! -z "$getvalue" ]] && yadfields+=("$getvalue") || yadfields+=("")
							;;
						num|numeric)
							yadfields+=("--field=$ydatat:NUM")
							getvalue="$(echo "$ydata2" | cut -d '#' -f 1)"
							[[ ! -z "$getvalue" ]] && yadfields+=("$getvalue") || yadfields+=("")
							;;
						sel|select|selectbox)
							yadfields+=("--field=$ydatat:CB")
							getvalue="$(echo "$ydata2" | cut -d '#' -f 1)"
							[[ ! -z "$getvalue" ]] && yadfields+=("$getvalue") || yadfields+=("")
							;;
						cbo|combo|combobox)
							yadfields+=("--field=$ydatat:CBE")
							getvalue="$(echo "$ydata2" | cut -d '#' -f 1)"
							[[ ! -z "$getvalue" ]] && yadfields+=("$getvalue") || yadfields+=("")
							;;
						*)
							;;
					esac
				else
					declare -A dmenufields
					declare -A dmenutitles
					case $ytype in
						preview)
							[[ "$ydata1" =~ (true|on|yes|enable|1) ]] && preview="1"
							[[ "$ydata1" =~ (false|off|no|disable|0) ]] && preview="0"
							;;
						num|numeric)
							dmenufields[$ydata1]="$(echo "$ydata2" | cut -d '!' -f 1 | cut -d '#' -f 1)"
							dmenutitles[$ydata1]="$(echo "$ydatat")"
							;;
						field|var|entry|text|txt|textarea|sel|select|selectbox|cbo|combo|combobox)
							dmenufields[$ydata1]="$(echo "$ydata2" | cut -d '#' -f 1)"
							dmenutitles[$ydata1]="$(echo "$ydatat")"
							;;
						*)
							;;
					esac
				fi
			fi
		done
	done
	if [[ "$yadform" == "1" ]] && [[ "${#yadfields[@]}" -gt "0" ]]; then
		ifs "p"
		yform=($(yform ${yadfields[@]}))
		[[ $? == 0 ]] || { log "Notice: aborted" || backwindow || exit $? ; }
		ifs "n"
		yfieldsstep=0
		for yfields in ${yfieldlist[@]}; do
			value=$(echo -e "${yform[$yfieldsstep]}")
			yfieldsstep=$((yfieldsstep+1))
			rexply+=($yfields)
			ifs "e"
			export rexply_${yfields}="$(echo $value | sed 's.,000000..')"
			ifs "n"
		done
	else
		[[ "$seetips" == "1" ]] && previewmsg=$(echo -en "\n                 --- Instructions ---\nEnter: submit input or selection (if matching any line)\nShift+enter: forcedly submit your input, ignore matches\nCtrl+y: paste primary X selection (ie: mouse highlight)\nCtrl+shift(or caps)+Y: paste from the regular clipboard") && previewmsglines="6" || previewmsglines="0"
		totalvars=${#dmfieldlist[@]}
		for dfields in "${dmfieldlist[@]}"; do
			totallines=0
			if [[ "$preview" -ge "1" ]]; then
				totallines=$(($totallines+3))
				totallines=$(($totallines+$previewmsglines))
				ifs "e"
				for selectitem in ${dmenufields[$dfields]}; do
					totallines=$(($totallines+1))
				done
				ifs "n"
				for dfieldsstep in ${dmfieldlist[@]}; do
					totallines=$(($totallines+1))
				done
				value=$( {
					echo -en "$( [[ ! -z "${dmenufields[$dfields]}" ]] && {
						ifs "e"
						for selectitem in ${dmenufields[$dfields]}; do
							echo $selectitem
						done
						ifs "n"
					} || echo "" )"
					echo -e "\n\n                   --- Preview ---" | to upper $toupper
					for dfieldsstep in ${dmfieldlist[@]}; do
						[[ "$dfields" == "$dfieldsstep" ]] && dmenufields[$dfieldsstep]="[ __________ ]"
						printf "%26s | %s\n" "${dmenutitles[$dfieldsstep]}" "${dmenufields[$dfieldsstep]}" | to upper $toupper
					done
					echo -en "$previewmsg" | to upper $toupper ;
				} | dmenu -w $wid -nf $dmenunf -nb $dmenunb -sf $dmenusf -sb $dmenusb -l $totallines $( [[ "$bottoms" != "0" ]] && echo "-b" ) -p "reXply | ${dmenutitles[$dfields]}:" ) || return 2
			else
				value=$( {
					[[ ! -z "${dmenufields[$dfields]}" ]] && {
						ifs "!"
						for selectitem in ${dmenufields[$dfields]}; do
							echo $selectitem
							totallines=$(($totallines+1))
						done
						ifs "n"
					} || echo ""
				} | dmenu -w $wid -nf $dmenunf -nb $dmenunb -sf $dmenusf -sb $dmenusb -l $vertlis $( [[ "$bottoms" != "0" ]] && echo "-b" ) -p "reXply | ${dmenutitles[$dfields]}:" ) || return 2
			fi
			dmenufields[$dfields]="$value" && rexply+=($dfields) && export rexply_${dfields}="$value" || log "Error: aborted" || exit $?
		done
	fi
	ifs "r"
}

yerror() {
	local yexit=$?
	log "Error: $@ ($yexit)"
	if [[ "$yademsg" == "1" ]]; then
		yad --on-top --center --image="dialog-error" --width="580" --title="reXply failed" --text="Error: $@ ($yexit)"
	else
		echo -e "\nError: $@ ($yexit)\n\n" | dmenu -w $wid $( [[ "$bottoms" != "0" ]] && echo "-b" ) -nf white -nb red -sf white -sb red -l 10 -p "reXply"
	fi
	backwindow
	return $yexit
}

yask() {
	if [[ "$yadform" == "1" ]]; then
		yad --on-top --center --question --title="reXply question" --text="$1"
	else
		answer=""
		while [[ "$answer" != "[1] Yes" ]] && [[ "$answer" != "[0] No" ]]; do
			answer=$(echo -e "[1] Yes\n[0] No\n$1" | dmenu -w $wid $( [[ "$bottoms" != "0" ]] && echo "-b" ) -nf white -nb darkgreen -sf darkgreen -sb white -l $vertlis -p "reXply | Confirmation") || log "Error: aborted" || exit $?
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
		xdotool windowactivate --sync $window 2>>$logfile || yerror "unable to focus the desired window to paste" || exit $?
		if [[ "$terminal" == "1" ]]; then
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
		case $copycmd in
			'1') getclipboard="xclip -selection $clipboard -o" ;;
			'2') getclipboard="xsel --$clipboard -o" ;;
			'3') getclipboard="pbpaste" ;;
			*) yerror "invalid \$copycmd value (set 1 for xclip, 2 for xsel, 3 for pbcopy/pbpaste)" || exit 1 ;;
		esac
		originalclipboard=$($getclipboard) || { yask "unable to backup current (empty?) clipboard data. proceed?" && originalclipboard="" || log "Notice: aborted" || backwindow || exit $? ; }
	fi
	if [[ "$copytoc" ]]; then
		case $copycmd in
			'1') cat $1 | xclip -selection $clipboard -i ;;
			'2') cat $1 | xsel --$clipboard -i ;;
			'3') cat $1 | pbcopy ;;
			*) yerror "invalid \$copycmd value (set 1 for xclip, 2 for xsel, 3 for pbcopy/pbpaste)" || exit 1 ;;
		esac
		[[ $? != 0 ]] && { yerror "unable to copy tmpfile $i to $clipboard" || exit $? ; }
	fi
	[[ "$pasteit" != "0" ]] && { ${paste} && sleep "${waitbit}s" || yerror "unable to paste data to pid $proc ($cmdline)" || exit $? ; }
	if [[ $restore != "0" ]]; then
		case $copycmd in
			'1') restoreclipboard="xclip -selection $clipboard" ;;
			'2') restoreclipboard="xsel --$clipboard -i" ;;
			'3') restoreclipboard="pbcopy" ;;
			*) yerror "invalid \$copycmd value (set 1 for xclip, 2 for xsel, 3 for pbcopy/pbpaste)" || exit 1 ;;
		esac
		echo -n "$originalclipboard" | $restoreclipboard || yerror "unable to restore original clipboard data" || exit $?
	fi
}

instdeps () {
	[[ ! -d "$HOME/.rexply" ]] && {
		mkdir -p "$HOME/.rexply"
		cp -Rv ./replies ~/.rexply/
		cp -v ./rexply.cfg ~/.rexply/
	}
	echo -e "Running install script - installing dependencies\n"
	errors='0'
	apps=('yad' 'dmenu' 'xdotool' 'xclip' 'xsel' 'wmctrl' 'pbcopy' 'pbpaste')
	sudo=$(which sudo || which gksudo || which kdesudo || which pkexec)
	[[ ! -z $sudo ]] || log "Error: can't determine sudo/gksudo/kdesudo/pkexec equivalent. Please install the packages:\n\n${apps[@]}" || errors='1'
	if [[ "$errors" == "0" ]]; then
		apt=$(which apt || which apt-get || which dnf || which yum || which brew)
		[[ ! -z $apt ]] || log "Error: can't determine your package manager. Please install the packages:\n\n${apps[@]}" || errors='1'
	fi
	if [[ "$errors" == "0" ]]; then
		for app in ${apps[@]}; do
			binary=$(which "${app}") && echo "Command '$app' is already available ($binary)." || {
				$sudo $apt install $app >/dev/null 2>&1 && echo "Package '$app' successfully installed." || log "Package '$app' not found." || errors='1'
			}
		done
	fi
	case $errors in
		0) echo -e "\nFinish. You can now run rexply (without parameters :)" ;;
		*) echo -e "\nFinish. Note: not all 'dependencies' are really necessary. You can give a try running rexply (without parameters :)" ;;
	esac
}

init() {
	apps=()
	bashing=""
	[[ "$execute" != "0" ]] && bashing="bash"
	[[ "$copytoc" != "0" ]] && [[ "$pasteit" != "1" ]] && restore="0"
	[[ "$cbackup" != "1" ]] && restore="0"
	[[ "$pasteit" != "1" ]] && focusit="0"
	for dirs in "$replies" "$(dirname $tmpfile)" "$(dirname $logfile)"; do
		if [[ ! -d "$dirs" ]] && [[ ! -f "$dirs" ]]; then
			mkdir -p "$dirs" || { echo "Error: unable to create directory: $dirs" >&2 ; exit 1 ; }
		fi
	done
	:>>$logfile || { echo "Error: logfile ($logfile) is not writable" ; exit 1 ; }
	:>$tmpfile || yerror "tmpfile ($tmpfile) is not writable" || exit $?
	if [[ "$focusit" == "1" ]]; then
		window=$(xdotool getactivewindow 2>>$logfile) || yerror "unable to detect active window" || exit $?
		proc=$(xdotool getwindowpid $window 2>>$logfile) || yerror "unable to obtain origin window pid (did the process terminate?)" || exit $?
		cmdline="$(cat /proc/$proc/cmdline | tr -d '\0' | to lower)" || yerror "unable to obtain active window cmdline" || exit $?
		[[ "$cmdline" =~ (terminal|terminator|tilix|tmux|tilda|guake) ]] && terminal="1" || terminal="0"
		[[ "$terminal" == "0" ]] && wid="$window" || wid="0"
	else
		terminal="0"
		wid="0"
	fi
	maxsize=$((maxsize+1))
	title=$replies
	case $dmenucc in
		0) colors=() ;;
		1) colors=("-nf" "$dmenunf" "-nb" "$dmenunb" "-sf" "$dmenusf" "-sb" "$dmenusb") ;;
	esac
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
			content="$(cat "$filename" | process "$filename")"
			case $? in
				0) ;;
				1) log "command processed successfully: '$content'"; exit 0 ;;
				*) exit $?
			esac
			if [[ "${#content}" == 0 ]]; then
				printf "$filename evaluated empty" > $tmpfile && yerror "output of $filename evaluation is empty" && exit 1
			else
				printf "%s" "$content" > $tmpfile || yerror "unable to write evaluation of $filename to tmpfile: $tmpfile" || exit $?
			fi
			[[ "$checkpt" == "1" ]] && checkpt $tmpfile || yerror "unable to remove the placeholder char at end of $tmpfile" || exit $?
			cat $tmpfile | pasteit $tmpfile || yerror "unable to paste data" || exit $?
			[[ "$deltemp" == "1" ]] && { rm -f $tmpfile || yerror "unable to remove tmpfile: $tmpfile" || exit $? ; }
		fi
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

s() {
	for subdirs in $(find -L $replies -mindepth 1 -maxdepth 1 ! -name .\* -type d -readable | sed "s@$replies@@g" | sort -n); do
		[[ "$subdirs" != "/."* ]] || [[ "$showall" == "1" ]] && options+=("$subdirs") && [[ "$yadfile" == "1" ]] && options+=(${ysubdir[@]})
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
	[[ "$seepath" == "1" ]] && dtitle=$(echo " Select from $1" | sed "s,$title,your repository,") || dtitle=""
	ifs "n"
	options=()
	tolistfunctions=('e' 'p' 's' 'f' 'c' 'h')
	for tolist in ${listord[@]}; do
		for tolistfunction in ${tolistfunctions[@]}; do
			[[ "$tolist" == "$tolistfunction" ]] && { $tolist || yerror "unable to process list of files" || exit $? ; }
		done
	done
	if [[ "$yadfile" == "1" ]]; then
		height=$(awk -v items=${#options[@]} -v ih=$peritem -v mh=$minimum 'BEGIN{printf "%d", ((items/3)*ih)+mh}')
		[[ "$timeout" -gt "0" ]] && height=$((height+10))
		name=$(yad --on-top --center --list --title="reXply" --text="$dtitle" --column="Files" --column="@fore@" --column="@back@" --no-headers --width="580" --height="$height" --timeout="$timeout" --timeout-indicator="top" --search-column="1" --regex-search ${options[@]} 2>/dev/null)
	else
		name=$( for dirorfile in ${options[@]}; do echo -e "$dirorfile"; done | dmenu -w $wid "${colors[@]}" $( [[ "$bottoms" != "0" ]] && echo "-b" ) -l $vertlis -i -p "reXply$dtitle" )
	fi
	case $? in
		0) ;;
		1) log "Notice: aborted by user" || backwindow || exit $? ;;
		70) yerror "timeout" || exit $? ;;
		252) log "Notice: aborted by user" || backwindow || exit $? ;;
		*) log "Unknow error: dir/file selection returned status code $?" || backwindow || exit $? ;;
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
	if [[ -d "$replies$name" ]]; then
		replies=$replies$name
		selectfile $replies || yerror "unable to navigate to subdirectory: $replies" || exit $?
		return 0
	else
		if [[ -f "$replies/$name" ]]; then
			echo "$replies/$name"
		else
			yerror "invalid directory/file: $replies/$name" || exit $?
		fi
	fi
	ifs "r"
}

pastepp() {
	pasteit='1'
	pastedefault="$1"
	pasteterminal="$1"
}

head="reXply is a handy tool to copy/paste replies and scripts with an advanced front-matter system for variables substitutions and dynamic per-template settings, bash script processing/evaluation, and much more, that can also be used as a launcher to other scripts/executables!"

showhelp() {
	echo "
	$head

	https://github.com/renatofrota/rexply

	Parameters:

	-a 0|1
		show All files (including hidden directories/files)
		directories/files starting with a dot (like .dir or .file) will be displayed
		0 to disable, 1 to enable
		current default: $showall

	-b 0|1
		pass template output to Bash (bash -c \"\${output}\")
		0 to disable, 1 to enable
		current default: $bashcmd

	-B 0|1
		place dmenu at Bottom of screen
		0 to disable, 1 to enable
		current default: $bottoms

	-c 0|1
		Copy processed data to clipboard
		0 to disable, 1 to enable
		current default: $copytoc

	-C 0|1
		backup Current clipboard data
		0 to disable, 1 to enable
		current default: $cbackup

	-d 0|1
		delete the tmp file after reply is processed/pasted
		0 to disable, 1 to enable
		current default: $deltemp

	-e 0|1
		vErtical listing
		0 to disable, 1 to enable
		current default: $vertlis

	-E 0|1
		process templates using eval (envsubst when disabled)
		envsubst do not run subshells (some additional security)
		may still be enabled individually in templates with 'runeval:1'
		0 to disable, 1 to enable
		current default: $runeval

	-f 0|1
		Focus the originally active window before pasting
		(prevents unwanted pastes to 'always-on-top' windows)
		0 to disable, 1 to enable
		current default: $focusit

	-F FILE
		set the config File to be loaded on init
		$HOME/.rexply/rexply.cfg is still loaded afterwards
		current default: $configf

	-h
		Show this help message

	-H
		Show version History (changelog)

	-I
		Install all regular usage dependencies:
		yad dmenu xdotool xclip xsel pbcopy pbpaste

		Not all apps are mandatory.
		e.g.: you can set 'yadform=0' or pass '-y 0 -Y 0' to use primarily 'dmenu'
		(templates enforcing 'editor:1' or 'yadform:1' won't run unless you change them to 0)

	-k 0|1
		Remove cheKpoints ('@' at the end of template files)
		0 to disable, 1 to enable
		current default: $checkpt

	-m 1..99
		Maximum file size to display (in megabytes)
		integer value (1, 5, 10, ...)
		current default: $maxsize

	-p 0|1
		Paste the reply
		note: if disabled implies -r 0 (do not restore original clipboard)
		0 to disable, 1 to enable
		current default: $pasteit

	-P 'command \$1'
		set the Paste command (for both terminal and regular windows)
		the variable '\$1' represents the tmpfile holding the processed data
		you will probably want to use single quotes and parse it using 'eval'
		note: implies -p 1 (enable pasting)
		example: -P 'eval cat \$1'

	-r 0|1
		Restore original clipboard data after reply is processed/pasted
		0 to disable, 1 to enable
		current default: $restore

	-R <path> | <file>
		Repository path (or a direct file to process/run)
		set a custom path from where to load the replies/templates/scripts

		it can be an absolute path (starting with /)
		it can be a relative path (relative to current default replies dir)
		it can be an absolute/relative path to a file to be processed/run

		tip: you can also pass the directory/file path as the first non-option argument

		current default: $replies

	-t 0..99
		Timeout in seconds for file selection (yad only)
		integer value, 0 to disable
		current default: $timeout

	-T
		Tail run log

	-v
		Show version number

	-V
		Show release notes

	-w 0.n
		Wait time (in seconds) after pasting (prevent pasting interruption)
		accepts integer or float (0.1, 0.5, 1, ...)
		current default: $waitbit

	-x
		set x bit on process execution for debug

	-X 0|1
		eXecute file directly
		if the file is executable and this is enabled, execute the file directly instead calling 'bash <file>'
		0 to disable, 1 to enable
		current default: $execute

	-y 0|1
		File selection interface
		0 to dmenu, 1 to yad
		current default: $yadfile

	-Y 0|1
		Form filling interface
		0 to dmenu, 1 to yad
		current default: $yadform
"
}

vversion() {
	echo "reXply $version$revision - https://github.com/renatofrota/rexply"
}

taillogs() {
	tail -F $logfile
}

vrelease() {
	vversion
	echo -e "\nRelease notes:\n"
	vhistory | awk "/^\tv$version/{i++}i>=1{print}" | awk "/^\tv/{i++}i<2{print}"
}

vhistory() {
	echo "
	$head

	https://github.com/renatofrota/rexply

	v0.1.8 - 2020-07-14
		[+] added \$bashcmd variable (set 1 to pass template output to 'bash -c')
		[+] new parameter to specify alternative config file (-F)
		[+] new parameter to install dependencies and init ~/.rexply config dir (-I)
		[+] load user settings from $HOME/.reply/rexply.cfg if it exists
		[+] load replies from $HOME/.reply/replies if it exists
		[+] new option to see path during file selection
		[+] new parameter to tail run logs (-T)
		[+] dmenu now embeds to active window instead grabbing keyboard system-wide
		[+] the use of custom colors for dmenu is now optional
		[*] dmenu custom colors changed to a more sober standard
		[*] dmenu placement now defaults to top of screen
		[*] improved yes/no confirmations in dmenu
		[*] yad is now on-top on all cases (I can't believe I missed this before)
		[*] modified some command-line parameters
		[*] improved exit codes handling a bit more
		[-] removed parameter -D (dependencies test)

	v0.1.7 - 2020-06-24
		[*] changed default app for dir/file selection and error messages to yad (from dmenu)
		[*] moved files above subdirs in dir/file selection dialogs
		[+] new sample data

	v0.1.6 - 2017-10-10
		[*] reorganized settings area in rexply.bash, fixed some typos and rexply.cfg path
		[+] added \$yademsg to control if yad or dmenu is used to display error messages dialogs
		[+] added \$yadicon to choose wheter an icon is displayed on yad forms or not (a custom icon can also be set)
		rev.b:
		[*] do not init yad when front-matter has no variables that asks for user input
		[*] updated dynamic questions syntax to match {{?this}} as well (no ending '?')

	v0.1.5 - 2017-10-08
		[+] added \$seetips option (splitting \$preview=1 or 2 in individual configuration variables!)
		[+] added \$toupper option (uppercase all letters in dmenu lines to prevent matching input data)
		rev.b:
		[*] fixed operations with xsel (\$copycmd=2)
		rev.c:
		[*] yad is now properly focused on init - and is now used for form fillings by default (\$yadform=1)
		[*] fixed an issue with \$toupper also affecting the dmenu options on select/combo front-matter vars

	v0.1.4 - 2017-10-08
		[+] \$preview now accepts a new value (2) - and defaults to 1 again
		[+] new special front-matter command 'keep' to retain special unused variables in template output instead stripping them out
		[*] processing of front-matter variables and {{?dynamic questions?}} unified (they are now combined and you need to fill only 1 form)
		[*] dynamic questions can now be used multiple times in the template and you will be asked it's value only once (like front-matter vars)

	v0.1.3 - 2017-10-08
		[*] clipboard manipulation functions do not run anymore when launching executable files
		[*] preview now defaults to 0
		[*] clipboard restoration now respects line breaks (and do not add trailing lines, rev.b)
		[*] improved vertical selection in dmenu when variables have multiple options

	v0.1.2 - 2017-09-28
		[+] added support to dynamic template questions in format {{?What do you want to put here?}} - a la Typinator

	v0.1.1 - 2017-09-28
		[*] improved templates evaluation
		[*] added a prefix to front-matter variables during processing to avoid conflicts with internal and environment vars
		[*] removed \$literal setting - any template with no front-matter is considered text-only and pasted as-is
		rev.b:
		[*] fixed an evaluation problem introduced in v0.1.1 rev.a
		[*] front-matter variables now accept empty values as defaults
		[*] dmenu now accepts empty values as well (if an option is selected, submit your input with shift-enter)

	v0.1.0 - 2017-09-24
		[+] added support to front-matter variables select, selectbox, combo, combobox in dmenu
		[*] now literal templates supports newlines, \$literal defaults to 1 again
		[*] added apt-get, dnf, yum as possible commands to install dependencies (rev.b)
		[*] improved script abortion/failures related logics and logs (rev.b)
		[+] added support to field titles (rev.c)

	v0.0.9 - 2017-09-24
		[+] new front-matter variable type: 'select' or 'selectbox' (a selectbox with pre-defined values) - only works with Yad for now
		[+] new front-matter variable type: 'combo' or 'combobox' (an editable selectbox with pre-defined values) - only works with Yad for now
		[*] literal templates and \$runeval=0 now respect newlines! -- \$runeval is now 0 by default :)

	v0.0.8 - 2017-09-23
		[+] config/front-matter var: 'literal' (treat template as a command line, do not substitute or run var or subshell)
		[+] added a special value to \$literal: 2 (consider only one-liners as literal by default)
		[+] config/front-matter var: 'runeval' (use eval to substitute variables and run subshells)
		[+] treat hidden subfolders (\"conf folders\") and hidden files differently (than regular folders and files)
		[+] added \$execute config (-X parameter) to control if files are executed directly or through bash (former \$bashing config)
		[*] aliased 'editor' front-matter variable as 'yadform' (so all front-matter made to override settings are named equally)

	v0.0.7 - 2017-09-20
		[*] -P now implies -p

	v0.0.6 - 2017-09-20
		[+] added -P parameter (to set paste command for both terminal and regular windows)
		[*] pasting is disabled and copycmd is set 3 (pbcopy/pbpaste) automatically on OSX

	v0.0.5 - 2017-09-20
		[*] improved logics (e.g.: skip clipboard restore when skip pasting and data is on clipboard)
		[*] moved example scripts to a single folder to keep replies directory clean
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

[[ -f "$configf" ]] && source $configf
[[ -d "${HOME}/.rexply/replies" ]] && replies="${HOME}/.rexply/replies"
[[ -f "${HOME}/.rexply/rexply.cfg" ]] && source "${HOME}/.rexply/rexply.cfg"

while getopts "a:b:c:C:d:e:E:f:F:hHIk:lm:p:P:r:R:t:TvVw:xX:y:Y:" opt; do
	case $opt in
		a) showall="$OPTARG" ;;
		b) bashcmd="$OPTARG" ;;
		B) bottoms="$OPTARG" ;;
		c) copytoc="$OPTARG" ;;
		C) cbackup="$OPTARG" ;;
		d) deltemp="$OPTARG" ;;
		e) vertlis="$OPTARG" ;;
		E) runeval="$OPTARG" ;;
		f) focusit="$OPTARG" ;;
		F) configf="$OPTARG" ;;
		h) showhelp ; exit 0 ;;
		H) vhistory ; exit 0 ;;
		I) instdeps ; exit 0 ;;
		k) checkpt="$OPTARG" ;;
		m) maxsize="$OPTARG" ;;
		p) pasteit="$OPTARG" ;;
		P) pastepp "$OPTARG" ;;
		r) restore="$OPTARG" ;;
		R) replies "$OPTARG" ;;
		t) timeout="$OPTARG" ;;
		T) taillogs ; exit 0 ;;
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

OLD_IFS=$IFS

ifs() {
	[[ "$1" == "!" ]] && IFS='!' && return 0
	[[ "$1" == "e" ]] && IFS='' && return 0
	[[ "$1" == "n" ]] && IFS=$'\n' && return 0
	[[ "$1" == "p" ]] && IFS=$'|' && return 0
	[[ "$1" == "r" ]] && IFS=$OLD_IFS && return 0
}

init && run $1
exit $?