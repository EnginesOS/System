FROM  enginesos/servicebase

RUN echo "Y" | adduser -q --disabled-password -uid 22006 mysql

RUN apt-get -y install mysql-server

ADD home home


EXPOSE 3306
EXPOSE 22

ENV ContUser mysql
ENV ContGrp mysql


CMD /home/init.sh