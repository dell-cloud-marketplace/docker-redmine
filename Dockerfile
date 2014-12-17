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
    supervisor

# Install Redmine
RUN mkdir -p /app/redmine && \
    wget -nv "http://www.redmine.org/releases/redmine-2.6.0.tar.gz" -O - | tar -zvxf - --strip=1 -C /app/redmine
ADD database.yml /app/redmine/config/database.yml
ADD nginx.conf /opt/nginx/conf/nginx.conf

# Copy configuration files
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD supervisord-nginx.conf /etc/supervisor/conf.d/supervisord-nginx.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_redmine_db.sh /create_redmine_db.sh
RUN chmod 755 /*.sh

# Expose port
EXPOSE 3306 80 443

CMD ["/run.sh"]
