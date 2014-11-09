FROM  engines/passenger

ADD home home
ADD engines home/engines

RUN chown 2666 `find /var /usr/share /usr/local /home -user ruby`
RUN /usr/sbin/usermod -u 2666 ruby
#CMD cd /home/app ; gem install bundle; env PORT=3000 sh  Procfile.sh

EXPOSE 3000



