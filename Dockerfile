FROM dell/passenger-base
MAINTAINER Dell Cloud Market Place <Cloud_Marketplace@dell.com>

# Set environment variable for package install
ENV DEBIAN_FRONTEND noninteractive

# Install Redmine dependencies 
RUN apt-get update && apt-get install -yq \
    mysql-server=5.5.40-0ubuntu0.14.04.1 \
    git \
    subversion \
    imagemagick \
    libmysqlclient-dev \
    libmagickwand-dev \
    pwgen \
    supervisor

# Download Redmine archive and create backup directories
RUN mkdir -p /app/redmine /tmp/redmine /tmp/nginx && \
    wget -nv "http://www.redmine.org/releases/redmine-2.6.0.tar.gz" -O - \
    | tar -zvxf - --strip=1 -C /tmp/redmine
ADD database.yml /tmp/redmine/config/database.yml
ADD nginx.conf /opt/nginx/conf/nginx.conf

# Make a copy of the nginx configuration folder, in case an empty or 
# non-existent host folder is specified for the volume. 
# We'll test for this in run.sh.
RUN cp -R /opt/nginx/conf /tmp/nginx

# Copy configuration files
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD supervisord-nginx.conf /etc/supervisor/conf.d/supervisord-nginx.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_redmine_db.sh /create_redmine_db.sh
RUN chmod 755 /*.sh

# Expose volume folder for Redmine
# Application, mysql data, nginx configuration and logs
VOLUME ["/app/redmine", "/var/lib/mysql", "/opt/nginx/conf", "/var/log/nginx"]

# Expose Redmine ports
EXPOSE 3306 80 443

CMD ["/run.sh"]
