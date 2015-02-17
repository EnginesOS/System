FROM busybox
RUN echo "Y" | adduser  -h /home/volmgr -uid 22007 volmgr
VOLUME /fs/

ENV ContUser volmgr
ENV ContGrp volmgr

ADD home /home

CMD /home/init.sh