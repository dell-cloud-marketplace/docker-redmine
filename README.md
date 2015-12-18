# docker-redmine
This image installs [Redmine](http://www.redmine.org/), an open-source, web-based project management tool that supports multiple features like issue tracking, project wiki and forums. 
The image extends [dell/docker-passenger-base](https://github.com/dell-cloud-marketplace/docker-passenger-base) which, in turn, adds Phusion Passenger and Ngnix to [dell/docker-rails-base](https://github.com/dell-cloud-marketplace/docker-rails-base/). Please refer to the image README.md files for further information.

## Components
The software stack comprises the following components:

Name              | Version    | Description
------------------|------------|------------------------------
Ubuntu            | Trusty             | Operating system
Redmine           | 3.0.1              | Project management system
MySQL             | 5.5                | Database
Phusion Passenger | see [docker-passenger-base](https://github.com/dell-cloud-marketplace/docker-passenger-base/)          | Application server
Nginx             | see [docker-passenger-base](https://github.com/dell-cloud-marketplace/docker-passenger-base/)            | Web server
Ruby              | see [docker-rails-base](https://github.com/dell-cloud-marketplace/docker-rails-base/) | Programming language
Ruby on Rails     | see [docker-rails-base](https://github.com/dell-cloud-marketplace/docker-rails-base/)     | Web application framework

## Usage

### Start the Container

#### Basic Usage
Start your container with:

* A named container (**redmine**)
* Ports 80, 443 (Nginx) and 3306 (MySQL) exposed

As follows:

```no-highlight
sudo docker run -d -p 80:80 -p 443:443 -p 3306:3306 --name redmine dell/redmine
```

<a name="advanced-usage"></a>
#### Advanced Usage
Start your container with:

* A named container (**redmine**)
* Ports 80, 443 (Nginx) and port 3306 (MySQL) exposed
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

### Check the Log Files

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
http://<ip_address>
```
Or:

```no-highlight
https://<ip_address>
```

The container supports SSL, via a self-signed certificate. **We strongly recommend that you connect via HTTPS**, if the container is running outside your local machine (e.g. in the Cloud). Your browser will warn you that the certificate is not trusted. If you are unclear about how to proceed, please consult your browser's documentation on how to accept the certificate.

The default credentials are **admin/admin**. Please change these details immediately (click on **Admin** on the right hand-side, then Edit).

Or with cURL:
```no-highlight
curl http://<ip_address>
```

### Nginx Configuration

If you used the volume mapping option as listed in the [Advanced Usage](#advanced-usage), you can directly change the Nginx configuration under **/data/nginx/** on the host. A restart of the Nginx server is required once changes have been made.
To restart the configuration, enter the container using [nsenter](https://github.com/dell-cloud-marketplace/additional-documentation/blob/master/nsenter.md), and do:

```no-highlight
supervisorctl restart nginx
```

As the Nginx service restarts, the child processes (Passenger) will also restart, spawning new PIDs. You will see messages similar to the following, in the Docker logs:

```no-highlight
2014-12-16 12:15:38,083 CRIT reaped unknown pid 2806)
2014-12-16 12:15:38,085 CRIT reaped unknown pid 2811)
2014-12-16 12:15:39,118 CRIT reaped unknown pid 2842)
```

## Getting Started

There is comprehensive online documentation on using Redmine, support forums and an online shared demo which you can try. The following links might assist you:

* [Redmine Guide](http://www.redmine.org/projects/redmine/wiki/Guide)
* [Redmine Forums](http://www.redmine.org/projects/redmine/boards)
* [Redmine Demo](http://demo.redmine.org/)

### Installing a plugin 

* Copy the plugin directory into **#{RAILS_ROOT}/plugins**.
If you used the volume mapping option as listed in the [Advanced Usage](#advanced-usage), you can directly copy the plugin directory under **/app/redmine/plugins** on the host
* If the plugin requires a migration, from within the container, run the following command in #{RAILS_ROOT} to upgrade your database:
```no-highlight
rake redmine:plugins:migrate RAILS_ENV=production
```
* From within the container, restart Redmine:
```no-highlight
supervisorctl restart nginx
```
* You should now be able to see the plugin listed in Administration -> Plugins on the Redmine console

## Reference

### Environmental Variables

Variable    | Default  | Description
------------|----------|------------------------------------
MYSQL_PASS  | *random* |Password for MySQL user **admin**
REDMINE_PASS| *random* |Password for MySQL user **redmine**

### Image Details

Pre-built Image | [https://registry.hub.docker.com/u/dell/redmine](https://registry.hub.docker.com/u/dell/redmine)
