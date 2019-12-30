#!/bin/bash
# db_init.sh

DATABASE_NAME=ce_dict.sqlite3
DB_BIN=sqlite3
NL=$'\r'
DICT_FILE=cedict_1_0_ts_utf-8_mdbg.txt

db_op() {
  echo "$1" | $DB_BIN $DATABASE_NAME 2>/dev/null
}

total_lines=$(wc -l $DICT_FILE | awk '{ print $1 }')

db_op "DROP TABLE dict"
db_op "CREATE TABLE dict (\
  id          INTEGER PRIMARY KEY AUTOINCREMENT , \
  simplified  VARCHAR(10), \
  traditional VARCHAR(10), \
  pinyin      VARCHAR(255), \
  definition  TEXT \
  )"

exec < $DICT_FILE
while read -r line
do
  line=${line%$NL}
  # ignore comment lines
  if [[ $line =~ ^\# ]]; then
    continue
  fi

  # EX:
  # 手機 手机 [shou3 ji1] /cell phone/mobile phone/CL:部[bu4],支[zhi1]/
  # CG1: traditional
  # CG2: simplified
  # CG3: pinyin
  # GG4: definition
  percent=$(echo "scale=2; ($count/$total_lines)*100" | bc)
  echo "$count/$total_lines ($percent%)"
  line=$(echo $line | sed "s/\"/'/g")
  insert_statement=$(echo $line |
    perl -n -e'/(.+?) (.+?) \[(.+?)\]\ \/(.+)\//
      && print "INSERT INTO dict (simplified, traditional, pinyin, definition)
      VALUES(\"$1\", \"$2\", \"$3\", \"$4\")"')
  db_op "$insert_statement"

  if [[ $? -ne 0 ]]; then
    echo $line
    echo $insert_statement
  fi

  count=$(( ${count-1} + 1 ))
done  
