# docker-redmine
This image installs [Redmine](http://www.redmine.org/) - an open-source web-based project management that supports multiple features like issue tracking, project wiki and forums. 
It extends the [dell/docker-passenger-base](https://github.com/dell-cloud-marketplace/docker-passenger-base) image which adds Phusion Passengner and Ngnix. Please refer to the README.md for selected images for further information.

## Components
The software stack comprises the following components:

Name              | Version    | Description
------------------|------------|------------------------------
Ubuntu            | Trusty             | Operating system
Redmine           | 2.6                | Project management system
MySQL             | 5.6                | Database
Phusion Passenger | see [docker-passenger-base](https://github.com/dell-cloud-marketplace/docker-passenger-base/)          | Web server
Nginx             | see [docker-passenger-base](https://github.com/dell-cloud-marketplace/docker-passenger-base/)            | HTTP server & Reverse proxy
Ruby              | see [docker-rails](https://github.com/dell-cloud-marketplace/docker-rails/) | Programming language
Ruby on Rails     | see [docker-rails](https://github.com/dell-cloud-marketplace/docker-rails/)     | Web application framework

## Usage

### 1. Start the container
If you wish to create data volumes, which will survive a restart or recreation of the container, please follow the instructions in [Advanced Usage](#advanced-usage).

#### A. Basic Usage
Start the container:

* A named container ("redmine")
* Ports 80, 443 (Nginx) and 3306 (MySQL port) exposed

As follows:

```no-highlight
sudo docker run -d -p 80:80 -p 443:443 -p 3306:3306 --name redmine dell/redmine
```

<a name="advanced-usage"></a>
#### B. Advanced Usage
Start your container with:

* A named container ("redmine")
* Ports 80, 443 (Nginx) and port 3306 (MySQL port) exposed
* Four data volumes (which will survive a restart or recreation of the container). The Redmine application files are available in **/app/redmine** on the host. The Nginx website configuration files are available in **/data/nginx** on the host. The Nginx log files are available in **/var/log/nginx** on the host. The MySQL data is available in ***/data/mysql*** on the host.
* A pre-defined password for the MySQL admin user.
* A pre-defined password for the MySQL redmine user.

As follows:

```no-highlight
sudo docker run -d \
 -p 80:80 \
 -p 443:443 \
 -p 3306:3306 \
 -v /app/redmine:/app/redmine \
 -v /var/log/nginx:/var/log/nginx \
 -v /data/nginx:/opt/nginx/conf \
 -v /data/mysql:/var/lib/mysql \
 -e MYSQL_PASS="mypass" \
 -e REDMINE_PASS="mypass" \
 --name redmine dell/redmine
```
