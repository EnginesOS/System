FROM  engines/servicebase

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 ; echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' |  tee /etc/apt/sources.list.d/mongodb.list ;apt-get update
RUN echo "Y" | adduser -q --disabled-password -uid 22008 mongo
RUN apt-get install -y mongodb-org

ADD home home

ENV ContUser mongo
ENV ContGrp mongo
USER mongo
CMD /home/init.sh