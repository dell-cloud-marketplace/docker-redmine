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

### 1. Start the Container

#### A. Basic Usage
To start the container with:

* A named container ("redmine")
* Ports 80, 443 (Nginx) and 3306 (MySQL port) exposed

Do:

```no-highlight
sudo docker run -d -p 80:80 -p 443:443 -p 3306:3306 --name redmine dell/redmine
```

<a name="advanced-usage"></a>
#### B. Advanced Usage
To start your container with:

* A named container ("redmine")
* Ports 80, 443 (Nginx) and port 3306 (MySQL port) exposed
* Four data volumes (which will survive a restart or recreation of the container). The Redmine application files are available in **/app/redmine** on the host. The Nginx website configuration files are available in **/data/nginx** on the host. The Nginx log files are available in **/var/log/nginx** on the host. The MySQL data is available in ***/data/mysql*** on the host.
* A pre-defined password for the MySQL admin user.
* A pre-defined password for the MySQL redmine user.

Do:

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

### 2. Check the Log Files

If you haven't defined a MySQL password, the container will generate a random one. Check the logs for the password by running: 

```no-highlight
sudo docker logs redmine
```

You will see output like the following:

```no-highlight
========================================================================
You can now connect to this MySQL Server using:

   mysql admin -u admin -pca1w7dUhnIgI --host <host>  -h<host> -P<port>

Please remember to change the above password as soon as possible!
MySQL user 'root' has no password but only allows local connections
========================================================================

========================================================================
You can now connect to the redmine MySQL database using:

     mysql -uredmine -pe2rae1jiefi -h<host> -P<port>

Please remember to change the above password as soon as possible!
========================================================================

```

Make a secure note of:

* The admin user password (in this case **ca1w7dUhnIgI**)
* The redmine user password (in this case **Me2rae1jiefi**)

Next, test the **admin** user connection to MySQL:

```no-highlight
mysql -uadmin -pca1w7dUhnIgI -h127.0.0.1 -P3306
```
## Test your Deployment

The Redmine application can take some time to run due to scripts executed at container start up. This usually is under a minute. You can check the progress by following the logs '**sudo docker logs --follow redmine**' until the Nginx service is running.

To access the website, open:
```no-highlight
http://localhost
```
Or:

```no-highlight
https://localhost
```

The container supports SSL, via a self-signed certificate. **We strongly recommend that you connect via HTTPS**, if the container is running outside your local machine (e.g. in the Cloud). Your browser will warn you that the certificate is not trusted. If you are unclear about how to proceed, please consult your browser's documentation on how to accept the certificate.

Or with cURL:
```no-highlight
curl http://localhost
```
### Nginx Configuration

If you used the volume mapping option as listed in the [Advanced Usage](#advanced-usage), you can directly change the Nginx configuration under **/data/nginx/** on the host. A restart of the Nginx server is required once changes have been made.

* Restart Nginx Configuration

```no-highlight
supervisorctl restart nginx
```

As the Nginx service does a restart the child processes (Passenger) will also do a restart, spawning a new pid. Please note the below message will occur in the docker logs as a result:

```no-highlight
2014-12-16 12:15:38,083 CRIT reaped unknown pid 2806)
2014-12-16 12:15:38,085 CRIT reaped unknown pid 2811)
2014-12-16 12:15:39,118 CRIT reaped unknown pid 2842)
```
## Reference

### Image Details

Pre-built Image   | [https://registry.hub.docker.com/u/dell/redmine](https://registry.hub.docker.com/u/dell/redmine)
