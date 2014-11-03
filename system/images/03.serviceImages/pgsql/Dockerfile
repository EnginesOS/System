FROM  engines/base

RUN echo "Y" | adduser -q --disabled-password -uid 22002 postgres

RUN apt-get -y install postgresql 
ADD home home

RUN mv /var/lib/postgresql /var/lib/postgresql_firstrun

ENV ContUser postgres
ENV ContGrp  postgres

CMD /home/init.sh