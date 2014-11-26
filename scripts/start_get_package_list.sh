#!/bin/bash
. /opt/patch_manager/db.conf
server_list=`mysql -h $DB_HOST -u $DB_USER -p"$DB_PASS" -Nse 'SELECT server_name from servers' $DB_NAME`
for i in `echo $server_list`; do
	/opt/patch_manager/queue_package_check.sh "$i" &
done
