#!/bin/bash
# main.sh

stty -echo

ESC=$( printf "\033" )
readonly ESC
IFS=
# input string
input_string=""

clear
while read -rs -n1 input 2>/dev/null >&2; do
  clear
  if [[ -z "$input" ]]; then
    # enter
    input_string=""
  elif [[ "$input" = "$ESC" ]]; then
    # left, right, down, up keys
    read -rsn2 input2 2>/dev/null >&2;
  elif [[ "$input" == $'\x7F' ]]; then
    # backspace
    if [[ -n "$input_string" ]]; then
      input_string=${input_string:0:$((${#input_string} - 1))}
    fi
  else
    # regular keypress
    # echo -n "$input" | xxd
    input_string+=$input
  fi
  echo "input_string: $input_string"
done
