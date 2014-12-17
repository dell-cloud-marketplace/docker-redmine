#!/bin/bash

VOLUME_HOME="/app"
VOLUME_MYSQL="/var/lib/mysql"
VOLUME_NGINX="/opt/nginx/conf"

# Test MySQL VOLUME_HOME_MYSQL has content
if [[ ! -d $VOLUME_MYSQL/mysql ]]; then
   echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_MYSQL"
   echo "=> Installing MySQL ..."
   mysql_install_db > /dev/null 2>&1
   echo "=> Done!"
   /create_redmine_db.sh
else
    echo "=> Using an existing volume of MySQL"
fi

# Start MySQL
/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
  echo "=> Waiting for confirmation of MySQL service startup"
  sleep 5
  mysql -uroot -e "status" > /dev/null 2>&1
  RET=$?
done

# Install gems required by Redmine 
cd /app/redmine
bundle install --without development test

# Generates a random key used by Rails to encode cookies storing session data 
# thus preventing their tampering.
rake generate_secret_token

mkdir public/plugin_assets
chown -R www-data:www-data files log tmp public/plugin_assets config.ru
chmod -R 755 files log tmp public/plugin_assets

# Creates the database structure
RAILS_ENV=production bundle exec rake db:migrate
#RAILS_ENV=production bundle exec rake redmine:load_default_data

exec supervisord -n 
