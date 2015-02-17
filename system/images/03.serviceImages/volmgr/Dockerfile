FROM engines/servicebase
RUN echo "Y" | adduser -q --disabled-password --home=/home/volmgr -uid 22007 volmgr
VOLUME /fs/

ENV ContUser volmgr
ENV ContGrp volmgr

ADD home /home
ADD custom_start.sh /home/engines/scripts/
CMD /home/init.sh