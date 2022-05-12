#!/bin/bash
# MySQL backup script
  for s in $(mysql --defaults-extra-file=/etc/my.cnf --skip-column-names -e "SHOW DATABASES");
  do
  mkdir -p $s
    for t in $(mysql --defaults-extra-file=/etc/my.cnf --skip-column-names $s -e "SHOW TABLES");
    do
    mysqldump --master-data=2 --add-drop-table --add-locks --create-options --disable-keys --extended-insert --single-transaction --quick --set-charset --events --routines --triggers $s | gzip -1 > $s/$t.gz;
    done
done