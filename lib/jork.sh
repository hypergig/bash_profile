#!/usr/bin/env bash

# Jordan Fork
# because impatience is one of the 3 great virtues of a programmer
# http://threevirtues.com/


colors=(
  # green
  '0;32'
  # brown/orange
  '0;33'
  # blue
  '0;34'
  # purple
  '0;35'
  # cyan
  '0;36'
  # light gray
  '0;37'
  # dark gray
  '1;30'
  # light green
  '1;32'
  # yellow
  '1;33'
  # light blue
  '1;34'
  # light purple
  '1;35'
  # light cyan
  '1;36'
  # white
  '1;37'
)


stdout(){
  while read; do
    printf "\e[${colors[$1]}mp${1} out | %s\e[m\n" "$REPLY"
  done
}


stderr(){
  while read; do
    printf "\e[0;31mp${1} err | %s\e[m\n" "$REPLY" 1>&2
  done
}


i=0
while read; do
  {
    exec 2> >(stderr $i)
    exec > >(stdout $i)
    eval "$REPLY"
  }&


  i=$(((i + 1) % 13))
done

wait
