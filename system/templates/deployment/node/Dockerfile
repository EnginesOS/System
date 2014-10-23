FROM  enginesos/node
ADD home home
ADD engines home/engines
ADD cron/ /etc/cron.d
RUN chown 2667 `find /var /usr/share /usr/local /home -user node`
RUN /usr/sbin/usermod -u 2667 node