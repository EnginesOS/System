FROM engines/servicebase:$release

RUN   apt-get -y update;\
		apt-get install -y  cmake make libnss-mysql-bg libpam-mysql mysql-client nfs-kernel-server rpcbind
	
COPY etc /etc/

RUN 	chmod 600 /etc/nss-mysql-root.conf ;\
	cd /tmp;\
	git clone --depth 1  git://github.com/nfs-ganesha.git;\	
	rm -rf build_dir; mkdir build_dir;\
  	cd build_dir;\
 	cmake /tmp/nfs-ganesha/src;\
	make;\
	make install
	
#USER nfsd