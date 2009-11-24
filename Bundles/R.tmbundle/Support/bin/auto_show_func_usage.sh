{
TEXT=$(cat)

export WORD=$(ruby -- <<-SCR1
print ENV['TM_CURRENT_LINE'][0...ENV['TM_LINE_INDEX'].to_i].gsub!(/ *$/, "").match(/[\w.]*$/).to_s
SCR1
)

#check whether WORD is defined otherwise quit
[[ -z "$WORD" ]] && exit 200

RD=$(echo -n "$TM_SCOPE" | grep -c -F 'source.rd.console')
[[ "${TM_CURRENT_LINE:0:1}" == "+" ]] && RD="0"
if [ $RD -gt 0 ]; then
	RDHOME="$HOME/Library/Application Support/Rdaemon"
	if [ "$TM_RdaemonRAMDRIVE" == "1" ]; then
		RDRAMDISK="/tmp/TMRramdisk1"
	else
		RDRAMDISK="$RDHOME"
	fi
	#get R's PID
	RPID=$(ps aw | grep '[0-9] /Lib.*TMRdaemon' | awk '{print $1;}' )

	#check whether Rdaemon runs
	if [ -z $RPID ]; then
		RDTEXT="•• Rdaemon is not running."
	else
		[[ -e "$RDRAMDISK"/r_tmp ]] && rm "$RDRAMDISK"/r_tmp

		TASK="@|sink('$RDRAMDISK/r_tmp')"
		echo "$TASK" > "$RDHOME"/r_in
		TASK="@|args($WORD)"
		echo "$TASK" > "$RDHOME"/r_in
		TASK="@|sink(file=NULL)"
		echo "$TASK" > "$RDHOME"/r_in

		while [ 1 ]
		do
			RES=$(tail -c 2 "$RDRAMDISK"/r_out)
			[[ "$RES" == "> " ]] && break
			[[ "$RES" == ": " ]] && break
			[[ "$RES" == "+ " ]] && break
			sleep 0.02
		done
		RES=$(cat "$RDRAMDISK"/r_tmp | sed 's/NULL$//;')

		[[ "$RES" == "NULL" ]] && RES=""

		if [ ! -z "$RES" ]; then
			echo -en "$WORD${RES:9}" | perl -pe 's/\n/ /g;s/ {2,}/ /g' | fmt | perl -e 'undef($/);$a=<>;$a=~s/\n/\n\t/g;$a=~s/\n\t$//;print $a'
			exit 206
		fi
	fi
fi


. "$TM_BUNDLE_SUPPORT"/bin/rebuild_help_index.sh

#get the reference for WORD
FILE=$(grep "^${WORD//./\\.}	" "$TM_BUNDLE_SUPPORT"/help.index | awk '{print $2;}')
#get the library in which WORD is defined
LIB=$(echo -en \"$FILE\" | perl -pe 's!.*/library/(.*?)/latex.*!$1!')
OUT=""
if [ ! -z "$FILE" -a ! -e "$FILE" ]; then
	PORT=""
	RPID=$(ps aw | grep '[0-9] /Lib.*TMRdaemon' | awk '{print $1;}' )
	#check whether Rdaemon runs
	if [ ! -z $RPID ]; then
		RDHOME="$HOME/Library/Application Support/Rdaemon"
		if [ "$TM_RdaemonRAMDRIVE" == "1" ]; then
			RDRAMDISK="/tmp/TMRramdisk1"
		else
			RDRAMDISK="$RDHOME"
		fi
		[[ -e "$RDRAMDISK"/r_tmp ]] && rm "$RDRAMDISK"/r_tmp
		TASK="@|sink('$RDRAMDISK/r_tmp')"
		echo "$TASK" > "$RDHOME"/r_in
		TASK="@|ifelse(!tools:::httpdPort,tools::startDynamicHelp(T),tools:::httpdPort)"
		echo "$TASK" > "$RDHOME"/r_in
		TASK="@|sink(file=NULL)"
		echo "$TASK" > "$RDHOME"/r_in
		while [ 1 ]
		do
			RES=$(tail -c 2 "$RDRAMDISK"/r_out)
			[[ "$RES" == "> " ]] && break
			[[ "$RES" == ": " ]] && break
			[[ "$RES" == "+ " ]] && break
			sleep 0.02
		done
		PORT=$(cat "$RDRAMDISK"/r_tmp | tail -n 1 | sed 's/.* //;')
		if [ "$PORT" == "0" -o -z "$PORT" ]; then
			echo -en "No Help Server found."
			exit 206
		fi
	fi
	if [ -z "$PORT" ]; then
		RPID=$(ps aw | grep '[0-9] /Lib.*TMRHelperDaemon' | awk '{print $1;}' )
		#check whether dummy daemon runs if not start it
		if [ -z $RPID ]; then
			WDIR="$TM_BUNDLE_SUPPORT"/bin
			cd "$WDIR"
			if [ ! -e /tmp/r_helper_dummy ]; then
				mkfifo /tmp/r_helper_dummy
			else
				if [ ! -p /tmp/r_helper_dummy ]; then
					rm /tmp/r_helper_dummy
					mkfifo /tmp/r_helper_dummy
				fi
			fi
			ruby Rhelperbuilder.rb &> /dev/null &
			### wait for Rhelper
			#safety counter
			SAFECNT=0
			while [ ! -f /tmp/r_helper_dummy_out ]
			do
				SAFECNT=$(($SAFECNT+1))
				if [ $SAFECNT -gt 50000 ]; then
					echo -en "Start failed! No response from R Helper server!"
					exit 206
				fi
				sleep 0.01
			done

			#wait for Rdaemon's output is ready
			SAFECNT=0
			while [ 1 ]
			do
				ST=$(tail -n 1 /tmp/r_helper_dummy_out )
				[[ "$ST" == "> " ]] && break
				SAFECNT=$(($SAFECNT+1))
				if [ $SAFECNT -gt 50000 ]; then
					echo -en "Start failed! No response from R Helper server!"
					exit 206
				fi
				sleep 0.05
			done
			sleep 0.1
		fi
		echo "ifelse(!tools:::httpdPort,tools::startDynamicHelp(T),tools:::httpdPort)" > /tmp/r_helper_dummy
		while [ 1 ]
		do
			RES=$(tail -c 2 /tmp/r_helper_dummy_out)
			[[ "$RES" == "> " ]] && break
			[[ "$RES" == ": " ]] && break
			[[ "$RES" == "+ " ]] && break
			sleep 0.02
		done
		PORT=$(cat /tmp/r_helper_dummy_out | tail -n 2 | head -n 1 | sed 's/.* //;')
	fi
	if [ "$PORT" == "0" -o -z "$PORT" ]; then
		echo -en "No Help Server found."
		exit 206
	fi
	FUN=$(echo -n "$FILE" | perl -pe 's!.*/library/(.*?)/latex/(.*?)\.tex$!$2!')
	OUT=$(curl -sS "http://127.0.0.1:$PORT/library/$LIB/html/$FUN.html" | perl -e 'undef($/);$w=$ENV{"WORD"};$a=<>;$a=~m!.*?<h\d>Usage</h\d>\s*<pre>.*?($w\(.*?\)).*?</pre>.*!s;print $1')
fi

#check whether something is found within the installed packages or within the current doc otherwise quit
if [ -z "$OUT" ]; then
	if [ -z "$FILE" ]; then #look for local defined functions
		OUT=$(echo -en "$TEXT" | egrep -A 10 "${WORD//./\\.} *<\- *function *\(" | perl -e '
			undef($/);$a=<>;$a=~s/.*?<\- *function *(\(.*?\)) *[\t\n\{\w].*/$1/s;
			$a=~s/\t//sg;$a=~s/\n/ /g;print "$a" if($a=~m/^\(/ && $a=~m/\)$/s)
		' | fmt | perl -e 'undef($/);$a=<>;$a=~s/\n/\n\t/g;$a=~s/\n\t$//;print $a')

		LIB="local"

		[[ -z "$OUT" ]] && exit 200

		OUT=$WORD$OUT
	
	else #get the usage from the latex file
		if [ -e "$FILE" ]; then
			OUT=$(cat "$FILE" | perl -e '
				undef($/);$w=$ENV{"WORD"};$a=<>;
				$a=~m/\\begin\{Usage\}\n\\begin\{verbatim\}\n?.*?($w *\(.*?\))\n.*?\\end\{verbatim\}/s;
				if(length($1)) {
					print $1;
				} else {
					$a=~m/\\begin\{Usage\}\n\\begin\{verbatim\}\n?.*?($w *\(.*?\)).*?\\end\{verbatim\}/s;
					print "$1";
				}
			')
		fi
	fi
fi

#if no usage is found show the HTML page for WORD otherwise output the command usage
if [ -z "$OUT" ]; then
	exit 200
else
	echo -en "$OUT"
fi

#output the library in which WORD is defined
if [ $RD -gt 0 -a "$LIB" != "base" ]; then
	echo -en "\n• Library “${LIB}” not yet loaded! [press CTRL+SHIFT+L]"
else
	echo -en "\n•• library: $LIB ••"
fi
echo -e "\n$RDTEXT"
} &