FROM  engines/node
ADD home home
ADD engines home/engines

RUN chown 2667 `find /var /usr/share /usr/local /home -user node`
RUN /usr/sbin/usermod -u 2667 node
CMD /home/start.bash