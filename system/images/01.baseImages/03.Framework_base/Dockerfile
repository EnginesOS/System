FROM  engines/base
ADD engines /home/engines
RUN apt-get install -y  mysql-client postgresql-client git-core imagemagick gawk sqlite3 bison  git-core sudo;\
	echo "includedir /etc/sudoers.d" >>/etc/sudoers;\
	mkdir -p /etc/sudoers.d;\
	mkdir -p /home/fs;\
	adduser -q --disabled-password  -uid 11111 data-user