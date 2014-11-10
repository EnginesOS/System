FROM  engines/passenger

ADD home home
ADD engines home/engines


RUN chown 2666 `find /var /usr/share /usr/local /home -user ruby`
RUN /usr/sbin/usermod -u 2666 ruby

ENV ContUser ruby
EXPOSE 3000



