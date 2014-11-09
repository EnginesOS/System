FROM  engines/passenger

RUN /usr/sbin/addgroup --gid 999 docker
RUN echo "Y" | adduser -q --uid 21000 --gid 999 --home /home/dockuser --disabled-password dockuser

ADD home home
ADD profile /home/dockuser/.profile


ENV ContUser dockuser
ENV ContGrp ruby
RUN mkdir -p /home/app 
WORKDIR /home/app/
RUN	git init

ADD gitconfig /home/app/.git/config

RUN /usr/local/rbenv/shims/gem install git bundle oink vmstat

RUN chown -R dockuser /home/app/ /home/dockuser /var/log/apache2/

RUN chmod -R g+w /usr/local/rbenv/versions/ ;chgrp -R docker /usr/local/rbenv/versions/
RUN chown -R dockuser /usr/local/rbenv/versions/$ruby_version/lib/ruby/gems/2.1.0/extensions


#After after chmod so not rewritable

ADD Procfile.sh /home/app/

CMD /home/app/Procfile.sh
USER 21000
GROUP 999