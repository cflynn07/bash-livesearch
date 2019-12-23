#!/bin/bash
# db_init.sh

DATABASE_NAME=ce_dict.sqlite3
DB_BIN=sqlite3
readonly DATABASE_NAME

echo "DROP TABLE tbl1" | $DB_BIN $DATABASE_NAME

echo "CREATE TABLE tbl1 (\
  id primary key, \
  simplified varchar(10), \
  traditional varchar(10), \
  pinyin varchar(100) \
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
  # 手機 手机 [shou3 ji1] /cell phone/mobile phone/CL:部[bu4],支[zhi1]/
  count=$(( count + 1 ))
done

echo "INSERT INTO tbl1 VALUES( \
  $count, \
  \"tim\" \
)" | $DB_BIN $DATABASE_NAME
  
