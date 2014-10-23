FROM enginesos/servicebase
RUN echo "Y" | adduser -q --disabled-password --home-dir=/home/volmgr -uid 22007 volmgr
VOLUME /fs/

ENV ContUser volmgr
ENV ContGrp volmgr

ADD home /home
ADD sudoers /etc/
RUN chown 0 /etc/sudoers
ADD volmgr.pub /home/volmgr/.ssh/authorized_keys
RUN chown rma -R /home/volmgr/.ssh