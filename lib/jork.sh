#!/usr/bin/env bash

# jordan fork
# because impatience is one of the 3 great virtues of a programmer
# http://threevirtues.com/
#
# helpful https://misc.flogisoft.com/bash/tip_colors_and_formatting
#

# blacklist colors that difficult to see against black or white backgrounds
blacklist=(0 1 7 9 {15..18} {232..235} {250..255})
colors=($(printf '%d\n' {0..255} ${blacklist[@]} | sort -n | uniq -u | sort -R))


stdout(){
  job=$1
  color=$((job % ${#colors[@]}))
  while read; do
    printf "\e[38;5;${colors[$color]}mj${job} out | %s\e[0m\n" "$REPLY"
  done
}


stderr(){
  job=$1
  while read; do
    printf "\e[1;31mj${job} err | %s\e[0m\n" "$REPLY" 1>&2
  done
}


# trap when a command fails and exit out
trap "printf '\e[1;31m%s\e[0m\n' 'NON-ZERO RETURN CODE - ABORTING!' 1>&2; exit 1" USR1

job=0
while read; do
  {
    exec 2> >(stderr $job)
    exec > >(stdout $job)

    bash <<< "$REPLY"
    rc=$?

    msg=">>> EXIT $rc <<<"
    if [ $rc -ne 0 ]; then
      echo "$msg" 1>&2
      kill -USR1 $$
    else
      echo "$msg"
    fi
  }&

  job=$((job + 1))
done

wait
