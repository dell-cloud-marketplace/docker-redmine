FROM dell/passenger-base:1.1
MAINTAINER Dell Cloud Market Place <Cloud_Marketplace@dell.com>

# Set environment variable for package install
ENV DEBIAN_FRONTEND noninteractive

# Install Redmine dependencies 
RUN apt-get update && apt-get install -yq \
    git \
    imagemagick \
    libmagickwand-dev \
    libmysqlclient-dev \
    mysql-server-5.5 \
    pwgen \
    subversion \
    supervisor

# Clean package cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Download Redmine archive and create backup directories
RUN mkdir -p /app/redmine /tmp/redmine /tmp/nginx && \
    wget -nv "http://www.redmine.org/releases/redmine-3.0.1.tar.gz" -O - \
    | tar -zvxf - --strip=1 -C /tmp/redmine
COPY database.yml /tmp/redmine/config/database.yml
COPY nginx.conf /opt/nginx/conf/nginx.conf

# Make a copy of the nginx configuration folder, in case an empty or 
# non-existent host folder is specified for the volume. 
RUN cp -R /opt/nginx/conf /tmp/nginx

# Copy configuration files
COPY run.sh /run.sh
COPY my.cnf /etc/mysql/conf.d/my.cnf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
COPY create_redmine_db.sh /create_redmine_db.sh
RUN chmod 755 /*.sh

# Expose volume folder for Redmine
# Application, mysql data, nginx configuration and logs
VOLUME ["/app/redmine", "/var/lib/mysql", "/opt/nginx/conf", "/var/log/nginx"]

# Environmental variables.
ENV MYSQL_PASS ""
ENV REDMINE_PASS ""

# Expose Redmine ports
EXPOSE 3306 80 443

CMD ["/run.sh"]