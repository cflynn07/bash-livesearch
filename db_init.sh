#!/bin/bash
# db_init.sh

DATABASE_NAME=ce_dict.sqlite3
DB_BIN=sqlite3
readonly DATABASE_NAME

echo "DROP TABLE dict" | $DB_BIN $DATABASE_NAME 2>/dev/null
echo "CREATE TABLE dict (\
  id          INTEGER PRIMARY KEY AUTOINCREMENT , \
  simplified  VARCHAR(10), \
  traditional VARCHAR(10), \
  pinyin      VARCHAR(255), \
  definition  TEXT \
  )" | $DB_BIN $DATABASE_NAME

count=1
NL=$'\r'

exec < cedict_1_0_ts_utf-8_mdbg.txt
while read -r line
do
  line=${line%$NL}
  if [[ $line =~ ^\# ]]; then
    continue
  fi

  # EX:
  # 手機 手机 [shou3 ji1] /cell phone/mobile phone/CL:部[bu4],支[zhi1]/
  # CG1: traditional
  # CG2: simplified
  # CG3: pinyin
  # GG4: definition

  echo "-----------------------"
  echo $line
  insert_statement=$(echo $line |
    perl -n -e'/(.+?) (.+?) \[(.+?)\]\ \/(.+)\//
      && print "INSERT INTO dict (simplified, traditional, pinyin, definition) VALUES(\"$1\", \"$2\", \"$3\", \"$4\")"')
  echo $insert_statement
  echo "-----------------------"
  echo $insert_statement | $DB_BIN $DATABASE_NAME

  if [[ $count -gt 1000 ]]; then
    exit
  fi
  count=$(( count + 1 ))

#  echo "INSERT INTO tbl1 VALUES( \
#    $count, \
#    \"tim\" \
#  )" | $DB_BIN $DATABASE_NAME
done  
