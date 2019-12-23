#!/bin/bash
# main.sh

stty -echo

ESC=$( printf "\033" )
readonly ESC

# input string
tty_input=""

clear

_process_input() {
  local input=$1
  clear
  if [[ -z "$input" ]]; then
    # enter
    tty_input=""
  elif [[ "$input" = "$ESC" ]]; then
    # left, right, down, up keys

    read -rsn2 input2 2>/dev/null >&2;
    echo "nonregular keypress"
    echo -n "$input$input2" | hexdump

  elif [[ "$input" == $'\x7F' ]]; then
    # backspace
    if [[ -n "$tty_input" ]]; then
      tty_input=${tty_input:0:$((${#tty_input} - 1))}
    fi
  else
    # regular keypress
    # echo -n "$input" | xxd
    echo "regular keypress"
    tty_input+=$input
  fi
  echo "tty_input: $tty_input"
}

while IFS= read -rs -n1 input 2>/dev/null >&2; do
  _process_input "$input"
done
