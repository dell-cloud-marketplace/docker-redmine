#!/bin/bash

REDMINE_APP="/app/redmine"

# Start MySQL
/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

PASS=${MYSQL_PASS:-$(pwgen -s 12 1)}
_word=$( [ ${MYSQL_PASS} ] && echo "preset" || echo "random" )
echo "=> Creating MySQL admin user with ${_word} password"

mysql -uroot -e "CREATE USER 'admin'@'%' IDENTIFIED BY '$PASS'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION"

echo "=> Done!"

echo "========================================================================"
echo "You can now connect to this MySQL Server using:"
echo ""
echo "    mysql -uadmin -p$PASS -h<host> -P<port>"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo "MySQL user 'root' has no password but only allows local connections"
echo "========================================================================"

# Create redmine user
REDMINE_USER_PASS=${REDMINE_PASS:-$(pwgen -s 12 1)}
_redmine_word=$( [ ${REDMINE_PASS} ] && echo "preset" || echo "random" )

echo "=> Creating MySQL redmine user with ${_redmine_word} password"
echo "=> Creating redmine database in MySQL"

# Create Redmine database
mysql -uroot -e "CREATE DATABASE redmine CHARACTER SET utf8; \
       GRANT ALL PRIVILEGES ON redmine.* TO 'redmine'@'%' \
       IDENTIFIED BY '$REDMINE_USER_PASS'; FLUSH PRIVILEGES;"

echo "=> Done!"

echo "========================================================================"
echo "You can now connect to the redmine MySQL database using:"
echo ""
echo "    mysql -uredmine -p$REDMINE_USER_PASS -h<host> -P<port>"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo "========================================================================"

# Inject Redmine mysql password in Redmine database.yml
sed -i 's/$REDMINE_DB_PWD/'$REDMINE_USER_PASS'/g' \
	$REDMINE_APP/config/database.yml

mysqladmin -uroot shutdown
