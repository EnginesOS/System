FROM  engines/base:$release

RUN echo "Y" | adduser -q --disabled-password -uid 22002 postgres

RUN apt-get update -y ;\
	 apt-get -y install postgresql postgresql-contrib libpq-dev;\
	apt-get clean
ADD home home
COPY pgpass /home/postgres/.pgpass

RUN mv /var/lib/postgresql /var/lib/postgresql_firstrun;\
 	chmod 600 /home/postgres/.pgpass ;\
 	 sed "/ssl-cert-snakeoil\.pem/s//engines\.crt/"  /etc/postgresql/9.3/main/postgresql.conf > /etc/postgresql/9.3/main/postgresql.conf.new ;\ 	 
 	 cp /etc/postgresql/9.3/main/postgresql.conf.new /etc/postgresql/9.3/main/postgresql.conf;\ 
 	 sed "/ssl-cert-snakeoil\.key/s//engines\.key/"  /etc/postgresql/9.3/main/postgresql.conf > /etc/postgresql/9.3/main/postgresql.conf.new ;\
 	 cp /etc/postgresql/9.3/main/postgresql.conf.new /etc/postgresql/9.3/main/postgresql.conf	 
ENV ContUser postgres
ENV ContGrp  postgres

CMD /home/init.sh