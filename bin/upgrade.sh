#!/bin/bash


function make_dirs {
mkdir -p  /var/lib/engines/backup_paths
mkdir -p  /var/lib/engines/fs
mkdir -p  /home/dockuser/droplets/deployment/deployed/
mkdir -p  /var/lib/engines/pgsql
mkdir -p  /var/lib/engines/mysql
mkdir -p  /var/lib/engines/mongo
mkdir -p  /var/log/engines/services/nginx/nginx
mkdir -p  /var/log/engines/services/backup
mkdir -p  /var/log/engines/services/mgmt
mkdir -p  /var/log/engines/services/pgsql/
mkdir -p  /var/log/engines/services/mysql/
mkdir -p  /var/log/engines/services/dns/
mkdir -p /var/log/engines/services/smtp/
mkdir -p /var/log/engines/containers/
mkdir -p /opt/engines/
mkdir -p  /var/lib/engines/mysql /var/log/engines/services/mysql/ /opt/engines/run/services/mysql_server/run/mysqld
mkdir -p /var/lib/engines/mysql /var/log/engines/services/mysql/ /opt/engines/run/services/mysql_server/run/mysqld
mkdir -p /var/lib/engines/psql /var/log/engines/services/psql	/opt/engines/run/services/pgsql_server/run/postgres
mkdir -p /var/log/engines/services/nginx /opt/engines/run/services/nginx/run/nginx
mkdir -p /var/lib/engines/mongo /var/log/engines/services/mongo	/opt/engines/run/services/mongo_server/run/mongo/

}

function set_permissions {
echo "Setting directory and file permissions"
	chown -R dockuser /opt/engines/ /var/lib/engines ~dockuser/  /var/log/engines
	chown -R 22006.22006  /var/lib/engines/mysql /var/log/engines/services/mysql/ /opt/engines/run/services/mysql_server/run/mysqld
	chown -R 22002.22002	/var/lib/engines/psql /var/log/engines/services/psql	/opt/engines/run/services/pgsql_server/run/postgres
	chown -R 22005.22005 /var/log/engines/services/nginx /opt/engines/run/services/nginx/run/nginx
    chown -R 22008.22008 /var/lib/engines/mongo /var/log/engines/services/mongo	/opt/engines/run/services/mongo_server/run/mongo/
	
	}

cd /opt/engos/
#su dockuser git pull

mv /opt/engos /opt/engines
mv /var/log/engos /var/log/engines
mv /var/lib/engos /var/lib/engines

make_dirs
set_permissions

cat ~dockuser/.profile |sed  "s/engos/engines/" >/tmp/t

cp /tmp/t ~dockuser/.profile
chown dockuser  ~dockuser/.profile

su -l dockuser  /opt/engines/bin/engines stop
su -l dockuser  /opt/engines/bin/eservices stop
 
docker stop `docker ps -a | grep -v CONTAINER|awk '{print $1}' `
 sleep 20
docker rm `docker ps -a | grep -v CONTAINER |awk '{print $1}' `


rvm alias  create default ruby-2.1.2

 su -l dockuser  /opt/engines/bin/eservices create
 su -l dockuser  /opt/engines/bin/engines create
 #su -l dockuser  /opt/engines/bin/containers_startup.sh 
 