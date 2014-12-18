#!/bin/bash

REDMINE_APP="/app/redmine"
REDMINE_APP_TMP="/tmp/redmine"
VOLUME_MYSQL="/var/lib/mysql"
NGINX_CONF="/opt/nginx/conf"
NGINX_CONF_TMP="/tmp/nginx/conf"

# Test if Redmine application folder has content
if [[ ! "$(ls -A $REDMINE_APP)" ]]; then
    cp -R $REDMINE_APP_TMP/* $REDMINE_APP
fi

# Test if nginx configuration folder has content
if [[ ! "$(ls -A $NGINX_CONF)" ]]; then
    cp -R $NGINX_CONF_TMP/* $NGINX_CONF
fi

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
cd $REDMINE_APP
bundle install --without development test

# Generates a random key used by Rails to encode cookies storing session data 
# thus preventing their tampering.
rake generate_secret_token

# Set files permissions
mkdir public/plugin_assets
chown -R www-data:www-data files log tmp public/plugin_assets config.ru
chmod -R 755 files log tmp public/plugin_assets

echo "=> Start database migration, this might take a while."
# Creates the database structure and load sample data
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production REDMINE_LANG=en-GB rake redmine:load_default_data

exec supervisord -n 
