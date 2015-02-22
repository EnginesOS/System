FROM  engines/base:$release

RUN echo "Y" | adduser -q --disabled-password -uid 22002 postgres

RUN apt-get update -y ;\
	 apt-get -y install postgresql postgresql-contrib libpq-dev;\
	apt-get clean
ADD home home
COPY pgpass /home/postgres/.pgpass

RUN mv /var/lib/postgresql /var/lib/postgresql_firstrun;\
 	chmod 600 /home/postgres/.pgpass
 	
ENV ContUser postgres
ENV ContGrp  postgres

CMD /home/init.sh