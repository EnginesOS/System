FROM  engines/node
ADD home home
ADD engines home/engines
ENV ContUser node
RUN chown 22673 `find /var /usr/share /usr/local /home -user node`
RUN /usr/sbin/usermod -u 22673 node
CMD /home/start.bash

