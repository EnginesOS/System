FROM engines/servicebase:$release

RUN   apt-get -y update;\
		apt-get install -y libnss-mysql-bg libpam-mysql mysql-client nfs-kernel-server rpcbind
	
COPY etc /etc/

RUN 	chmod 600 /etc/nss-mysql-root.conf
	
#USER nfsd