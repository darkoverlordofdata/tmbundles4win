
[[ -n "$TM_SELECTED_TEXT" ]] && echo "Please unselect first." && exit 206

TEXT=$(cat)
#look for nested commands and set WORD to the current one
export WORD=$(perl -e '
$line=$ENV{"TM_CURRENT_LINE"};
$col=$ENV{"TM_LINE_INDEX"};
$line=substr($line,0,$col);
$line=~s/ //g;
@arr=split(//,$line);$c=0;
for($i=$#arr;$i>-1;$i--){$c-- if($arr[$i] eq ")");$c++ if($arr[$i] eq "(");last if $c>0;}
substr($line,0,$i)=~m/([\w\.]+)$/;
print $1 if defined($1);
')

#check whether WORD is defined otherwise quit
[[ -z "$WORD" ]] && echo "No keyword found" && exit 206

RD=$(echo -n "$TM_SCOPE" | grep -c -F 'source.rd.console')

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
		RDTEXT="Rdaemon is not running."
	else
		if [ -e "$HOME/Library/Application Support/TextMate/R/help/command_args/$WORD" ]; then
			export RES=$(cat "$HOME/Library/Application Support/TextMate/R/help/command_args/$WORD" | perl -pe 's/\|/###/g;s/\n/|/g;s/ //g;')
		else
			[[ -e "$RDRAMDISK"/r_tmp ]] && rm "$RDRAMDISK"/r_tmp
			TASK="@|sink('$RDRAMDISK/r_tmp')"
			echo "$TASK" > "$RDHOME"/r_in
			#TASK="@|args("${WORD//./\\.}")"
			TASK="@|args("$WORD")"
			echo "$TASK" > "$RDHOME"/r_in
			TASK="@|sink(file=NULL)"
			echo "$TASK" > "$RDHOME"/r_in
			while [ 1 ]
			do
				RES=$(tail -c 2 "$RDRAMDISK"/r_out)
				[[ "$RES" == "> " ]] && break
				sleep 0.02
			done
			export RES=$(cat "$RDRAMDISK"/r_tmp | perl -e '
			undef($/);$a=<>;
			$a=~s/NULL$//;
			$a=~s/\n//mg;
			$a=~s/^function \(//;
			$a=~s/ //g;
			$a=~s/\)$//;
			$a=~s/,\.{3}//g;
			$a=~s/\.{3},//g;
			$a=~s/\.{3}//g;
			$a=~s/^([\w\.]+)\,/$1=|/g;
			$a=~s/^([\w\.]+)\|/$1=|/g;
			$a=~s/[,\|]([\w\.]+)=/|$1=/g;
			$a=~s/[,\|]([\w\.]+)[,\|]/|$1=|/g;
			print $a
			')
		fi
	fi
else

	#check for user-defined parameter list
	if [ -e "$HOME/Library/Application Support/TextMate/R/help/command_args/$WORD" ]; then
		export RES=$(cat "$HOME/Library/Application Support/TextMate/R/help/command_args/$WORD" | perl -pe 's/\|/###/g;s/\n/|/g;s/ //g;')
	else
		. "$TM_BUNDLE_SUPPORT"/bin/rebuild_help_index.sh

		IS_HELPSERVER=$(cat "$TM_BUNDLE_SUPPORT"/isHelpserver)
		PORT=0
		HELPPIPE_IN=""
		HELPPIPE_OUT=""

		if [ "$IS_HELPSERVER" == "TRUE" ]; then
			## Find or start a Help Server 
			# Check if Rdaemon runs, if so use that http help server
			RD=$(echo -n "$TM_SCOPE" | grep -c -F 'source.rd.console')
			RDOFF=$(echo -n "$TM_SCOPE" | grep -c -F 'source.r')
			[[ "${TM_CURRENT_LINE:0:1}" == "+" ]] && RD="0"
			if [ $RD -gt 0 -o $RDOFF -gt 0 ]; then
				#get R's PID
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
					HELPPIPE_IN="$RDHOME/r_in"
					HELPPIPE_OUT="$RDRAMDISK/r_tmp"
				fi
			fi
			# If no Rdaemon runs start a dummy helper daemon
			if [ $RDOFF -gt 0 ]; then
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
				HELPPIPE_IN="/tmp/r_helper_dummy"
				HELPPIPE_OUT="/tmp/r_helper_dummy_out"
			fi
			if [ "$PORT" == "0" -o -z "$PORT" ]; then
				echo -en "No Help Server found."
				exit_show_tool_tip
			fi
			echo "$PORT" > "$TM_BUNDLE_SUPPORT"/httpPort
		fi


		#get the reference for WORD
		FILE=$(grep "^${WORD//./\\.}	" "$TM_BUNDLE_SUPPORT"/help.index | awk '{print $2;}')

		if [ "$IS_HELPSERVER" == "TRUE" ]; then
			FUN=$(echo -n "$FILE" | perl -pe 's!.*/library/(.*?)/latex/(.*?)\.tex$!$2!')
			LIB=$(echo -n "$FILE" | perl -pe 's!.*/library/(.*?)/latex/(.*?)\.tex$!$1!')
			OUT=$(curl -sS "http://127.0.0.1:$PORT/library/$LIB/html/$FUN.html" | perl -e 'undef($/);$w=$ENV{"WORD"};$a=<>;$a=~m!.*?<h\d>Usage</h\d>\s*<pre>.*?($w\(.*?\)).*?</pre>.*!s;print $1')
		else
			#get the usage from the latex file
			if [ -z "$FILE" ]; then # try to find a local declaration
					OUT=$(echo -en "$TEXT" | egrep -A 10 "${WORD//./\\.} *<\- *function *\(" | perl -e 'undef($/);$a=<>;$a=~s/.*?<\- *function *(\(.*?\)) *[\t\n\{\w].*/$1/s;$a=~s/\t//sg;print "$a" if($a=~m/^\(/ && $a=~m/\)$/s)')
			else
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
		#if no usage is found quit
		[[ -z "$OUT" ]] && echo "Nothing found" && exit 206

		#get only the parameters
		export RES=$(echo -en "$OUT" | perl -e '
			undef($/);$a=<>;
			$w=$ENV{"WORD"};
			$a=~s/\n//g;
			$a=~s/^$w *\(//;
			$a=~s/^\(//;
			$a=~s/ //g;
			$a=~s/\)$//;
			$a=~s/,\.{3}//g;
			$a=~s/\.{3},//g;
			$a=~s/\.{3}//g;
			$a=~s/^([\w\.]+)\|/$1=|/g;
			$a=~s/^([\w\.]+)\,/$1=|/g;
			$a=~s/,([\w\.]+)=/|$1=/g;
			$a=~s/,([\w\.]+),/|$1=|/g;
			$a=~s/\|([\w\.=]+),/|$1=|/g;
			$a=~s/\|([\w\.]+)\|/|$1=|/g;
			$a=~s/\|([\w\.]+)$/|$1=/g;
			print $a;
		')

	fi

fi

#if no parameter quit
if [ -z "$RES" ]; then
	echo -n "Nothing found"
	[[ $RD -gt 0 ]] && echo " or library not yet loaded"
	exit 206
fi

#show all parameters as inline menu and insert the parameter as snippet (if '=' is found only the value)
ruby -- <<-SCRIPT
# 2> /dev/null
require File.join(ENV["TM_SUPPORT_PATH"], "lib/exit_codes.rb")
require "#{ENV["TM_SUPPORT_PATH"]}/lib/ui"
word = "$WORD"
text = ENV["RES"]
funs = text.split("\|")
funs.collect! {|x| x.gsub(/=/, " = ").gsub(/###/,"|")}
funs.each_index do |x|
	a=funs[x].count "("
	b=funs[x].count ")"
	if a!=b
		for i in (x+1..funs.size-1)
			funs[x] = funs[x] + ", " + funs[i]
			if funs[i].match('\)')
				funs[i] = "..."
				break
			else
				funs[i] = "..."
			end
		end
	end
end
funs.delete_if {|x| x == "..." }
TextMate.exit_discard if funs.size < 1

if funs.size == 1
  function = funs.first
else
	funs.unshift("-")
	funs.unshift("All Parameters")
	idx = TextMate::UI.menu(funs)
	TextMate.exit_discard if idx.nil?
	function = funs[idx]
end
TextMate.exit_discard if function.empty?
curword = ENV['TM_CURRENT_WORD']
comma=""
line, col = ENV['TM_CURRENT_LINE'], ENV['TM_LINE_INDEX'].to_i
left  = line[0...col].to_s
sp = left.match(/.$/).to_s
left.gsub!(/ +$/,'')
left = left.match(/.$/).to_s
comma = "\${2:, }" if left != "(" && left != ","
comma = " " + comma if sp == ","
if function == "All Parameters"
	cnt=1
	com=""
	snip=""
	funs.slice!(0)
	funs.slice!(0)
	funs.each do |item|
		com = ", " if cnt > 1
		if item.match("=")
			arr = item.gsub(/ = /, "=").match('([^=]+?)=(.*)')
			if arr[2].match('^\"')
				print "#{com}#{arr[1]} = \"\${"
				print cnt.to_s
				cnt+=1
				print ":#{arr[2].gsub(/\"/, "").gsub(/=/, " = ")}}\""
			else
				if arr[2].match('^c\(')
					print "#{com}#{arr[1]} = c(\${"
					print cnt.to_s
					cnt+=1
					print ":#{arr[2].gsub(/^c\(/, "").gsub(/\)\Z/,"").gsub(/=/, " = ")}})"
				else
					print "#{com}#{arr[1]} = \${"
					print cnt.to_s
					cnt+=1
					print ":#{arr[2].gsub(/=/, " = ")}}"
				end
			end
		else
			print "#{com}#{item} = \${"
			print cnt.to_s
			cnt+=1
			print ":}"
		end
	end
	print "\${#{cnt}:}"
else
	if function.match("=")
		arr = function.gsub(/ = /, "=").match('([^=]+?)=(.*)')
		if arr[2].match('^\"')
			print "#{comma}#{arr[1]} = \"\${1:#{arr[2].gsub(/\"/, "")}}\"\${3:}"
		else
			if arr[2].match('^c\(')
				subarr = arr[2].gsub(/^c\(/, "").gsub(/\)$/,"").gsub(/ /,"").split(",")
				for i in (0..(subarr.size - 1))
					subarr[i] = "\${#{i+3}:#{subarr[i]}}"
				end
				print "#{comma}#{arr[1]} = \${1:c(#{subarr.join(", ")})}\${300:}"
			else
				print "#{comma}#{arr[1]} = \${1:#{arr[2].gsub(/=/, " = ")}}\${3:}"
			end
		end
	else
		print "#{comma}#{function} = \${1:}\${3:}"
	end
end
SCRIPT
