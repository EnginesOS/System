FROM  enginesos/servicebase

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 ; echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' |  tee /etc/apt/sources.list.d/mongodb.list ;apt-get update
RUN echo "Y" | adduser -q --disabled-password -uid 22008 mongo
RUN apt-get install -y mongodb-org

ADD home home

#RUN echo "Y" | adduser -q --home /home/rma --disabled-password rma
#ADD sudoers /etc/

#ADD mongo.pub /home/rma/.ssh/authorized_keys
#RUN chown -R rma /home/rma/.ssh
#RUN chmod -R  700 /home/rma/.ssh

EXPOSE 3306
EXPOSE 22

ENV ContUser mongo
ENV ContGrp mongo


CMD /home/init.sh