FROM  engines/base

RUN echo "Y" | adduser -q --disabled-password -uid 22002 postgres

RUN apt-get -y install postgresql 
ADD home home
COPY pgpass 
RUN mv /var/lib/postgresql /var/lib/postgresql_firstrun
RUN chmod 600 /home/postgres/.pgpass
ENV ContUser postgres
ENV ContGrp  postgres

CMD /home/init.sh