#!/bin/sh

DATABASE=$(jq -r '.Dhcp4."lease-database"' /etc/kea/kea-dhcp4.conf)
DBHOST=$(echo "$DATABASE" | jq -r '.host')
DBPORT=$(echo "$DATABASE" | jq -r '.port')
DBUSER=$(echo "$DATABASE" | jq -r '.user')
DBNAME=$(echo "$DATABASE" | jq -r '.name')
TYPE=$(echo "$DATABASE" | jq -r '.type')
PASS=$(echo "$DATABASE" | jq -r '.password')

echo "Waiting for PostgreSQL..."
while ! pg_isready -d $DBNAME -U $DBUSER -h $DBHOST -p $DBPORT; do
    sleep 5s
done

version=$(kea-admin db-version pgsql -u ${DBUSER} -p ${PASS} -n ${DBNAME} -h ${DBHOST})
if [ -z $version ]; then
	kea-admin db-init pgsql -u ${DBUSER} -p ${PASS} -n ${DBNAME} -h ${DBHOST}
else
	kea-admin db-upgrade pgsql -u ${DBUSER} -p ${PASS} -n ${DBNAME} -h ${DBHOST}
fi

kea-dhcp4 -c /etc/kea/kea-dhcp4.conf
