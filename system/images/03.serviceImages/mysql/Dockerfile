FROM  engines/servicebase

RUN echo "Y" | adduser -q --disabled-password -uid 22006 mysql

RUN   apt-get -y update;\
	apt-get -y install mysql-server;\
	apt-get clean
ADD home home


EXPOSE 3306


ENV ContUser mysql
ENV ContGrp mysql


CMD /home/init.sh