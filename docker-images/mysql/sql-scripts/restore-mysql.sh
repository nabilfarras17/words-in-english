#!/bin/bash

modules="wn"
dbtype=mysql

function deletedb()
{
	echo "delete ${MYSQL_DATABASE}"
	mysql -u"${MYSQL_USERNAME}" -p"${MYSQL_PASSWORD}" -e "DROP DATABASE ${MYSQL_DATABASE};"
}

function createdb()
{
	echo "create ${MYSQL_DATABASE}"
    mysql -u"${MYSQL_USERNAME}" -p"${MYSQL_PASSWORD}" -e "CREATE DATABASE ${MYSQL_DATABASE} DEFAULT CHARACTER SET UTF8;"
}

function usedb()
{
    mysql -u"${MYSQL_USERNAME}" -p"${MYSQL_PASSWORD}" -e "USE ${MYSQL_DATABASE};"
}

function process()
{
	if [ ! -e "$1" ];then
		return
	fi
	mysql -u"${MYSQL_USERNAME}" -p"${MYSQL_PASSWORD}" $4 $3 < $1
}

echo "starting restore ${MYSQL_DATABASE}"
deletedb
createdb
usedb

for m in ${modules}; do
	sql=./${dbtype}-${m}-schema.sql
	process ${sql} "schema ${m}" ${MYSQL_DATABASE}
done
for m in ${modules}; do
	sql=./${dbtype}-${m}-data.sql
	process ${sql} "data ${m}" ${MYSQL_DATABASE}
done
for m in ${modules}; do
	sql=${dbtype}-${m}-unconstrain.sql
	process ${sql} "unconstrain ${m}" ${MYSQL_DATABASE} --force 2> /dev/null
	sql=${dbtype}-${m}-constrain.sql
	process ${sql} "constrain ${m}" ${MYSQL_DATABASE} --force
done
for m in ${modules}; do
	sql=${dbtype}-${m}-views.sql
	process ${sql} "views ${m}" ${MYSQL_DATABASE}
done
echo "ended restore ${MYSQL_DATABASE}"