#!/usr/bin/env bash
# - very minor revision could make not bash-specific, but i only actually use this in my bash startup scripts ~/sh/stopwatch
# - John Newman jnn@synfin.org

stopwatch()
{
    secs="unlimited"
    test -n "$1" && secs="$1"

    date1=$(date +%s); 
    s1=$(date '+%s')
    while true ; do
        echo -ne "$(date -u --date @$(($(date +%s) - $date1)) +%H:%M:%S)\r"; 
        test "$secs" = "unlimited" && continue
        test "$secs" = "0" && break
        s2=$(date '+%s')
        if [[ "$s2" > "$s1" ]]; then 
            s1=$s2
            secs=$((secs - 1))
        fi
    done     

}

if [[ "$1" =~ ^-h|--help ]] ; then
  echo "Usage: $0 [seconds]"
  echo "Provides a stop watch, [seconds] argument is optional - it will stop when it has counted that many seconds, if the argument is provided"
  exit 0
fi
 
stopwatch $1
