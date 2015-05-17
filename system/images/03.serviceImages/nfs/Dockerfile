FROM engines/servicebase:$release

RUN   apt-get -y update;\
		apt-get install -y   libnss-mysql-bg libpam-mysql mysql-client rpcbind nfs-kernel-server 
	
COPY etc /etc/

RUN 	chmod 600 /etc/nss-mysql-root.conf ;\
	adduser --uid 22018 -q --home /home/nfs --disabled-password samba
	
	
#USER nfs