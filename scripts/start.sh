#!/bin/sh

DATABASE=$(jq -r '.Dhcp4."lease-database"' /etc/kea/kea-dhcp4.conf)
DBHOST=$(echo "$DATABASE" | jq -r '.host')
DBPORT=$(echo "$DATABASE" | jq -r '.port')
DBUSER=$(echo "$DATABASE" | jq -r '.user')
DBNAME=$(echo "$DATABASE" | jq -r '.name')
TYPE=$(echo "$DATABASE" | jq -r '.type')
PASS=$(echo "$DATABASE" | jq -r '.password')

while ! pg_isready -d $DBNAME -U $DBUSER -h $DBHOST -p $DBPORT; do
    sleep 5s
    echo "Waiting for PostgreSQL..."
done

kea-admin db-version pgsql -u ${DBUSER} -p ${PASS} -n ${DBNAME} -h ${DBHOST}
retVal=$?
if [ ! $retVal -ne 0 ];then
	kea-admin db-init pgsql -u ${DBUSER} -p ${PASS} -n ${DBNAME} -h ${DBHOST}
else
	kea-admin db-upgrade pgsql -u ${DBUSER} -p ${PASS} -n ${DBNAME} -h ${DBHOST}
fi

kea-dhcp4 -c /etc/kea/kea-dhcp4.conf
