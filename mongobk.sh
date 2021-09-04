#!/bin/bash
#################################################################
#################CYWEAP##########################################
#################################################################
dbuser='<db user>'
dbpasswd='<db password>'
dbhost='localhost'
dbfind="$(mongo -u $dbuser -p $dbpasswd --eval  "printjson(db.adminCommand('listDatabases'))" | awk '/name/ {print $3}' | grep -v "admin\|config\|local"| tr -d '"'\|',')"
if [ -d /dbbackup ]; # By default backup location is "/dbbackup"
        then
                echo "DBBACKUP Directory Found"
        else
                mkdir /dbbackup
                echo "DBBACKUP Directory Created"
fi
if [ -d /dbbackup/"$(date +%d%m%Y)" ];
        then
                echo "$(date +%d%m%Y) Directory Found"
        else
                mkdir /dbbackup/"$(date +%d%m%Y)"
                echo "$(date +%d%m%Y) Directory Created"
fi

echo -e "$dbfind \n" | while read dbname; do mongodump -u $dbuser -p $dbpasswd --host="$dbhost" --authenticationDatabase="admin" --db="$dbname" --out=/dbbackup/"$(date +%d%m%Y)"/"$dbname""$(date +%d%m%Y)" --gzip; done


#Backup Details
echo "BackUp Location /dbbackup/$(date +%d%m%Y)" > $PWD/backupreport"$(date +%d%m%Y)".txt
echo "BackUp DatabaseFiles" >> $PWD/backupreport"$(date +%d%m%Y)".txt
ls -al /dbbackup/$(date +%d%m%Y) >> $PWD/backupreport"$(date +%d%m%Y)".txt

echo "30 days deleted files list" >> $PWD/backupreport"$(date +%d%m%Y)".txt
find /dbbackup/ -type d -mtime +29 -print >> $PWD/backupreport"$(date +%d%m%Y)".txt
find /dbbackup/ -type d -mtime +29 -exec rm -rf {} \;

cat $PWD/backupreport"$(date +%d%m%Y)".txt
echo "Backup successfully completed"

#for email report
#mail -s "Backup successfully completed" -t user@example.com < $PWD/backupreport"$(date +%d%m%Y)".txt
exit
