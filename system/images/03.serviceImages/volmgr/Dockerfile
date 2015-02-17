FROM busybox
RUN echo "Y" | adduser --disabled-password --home=/home/volmgr -uid 22007 volmgr
VOLUME /fs/

ENV ContUser volmgr
ENV ContGrp volmgr

ADD home /home

CMD /home/init.sh