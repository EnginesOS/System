FROM  engines/passenger

RUN /usr/sbin/addgroup --gid 999 docker
RUN echo "Y" | adduser -q --uid 21000 --gid 999 --home /home/dockuser --disabled-password dockuser

ADD home home
ADD profile /home/dockuser/.profile


ENV ContUser dockuser
ENV ContGrp ruby

RUN chown -R dockuser /home/app/ /var/log/apache2 
RUN chmod -R g+w /usr/local/rbenv/versions/ ;chgrp -R docker /usr/local/rbenv/versions/
RUN chown -R dockuser /usr/local/rbenv/versions/2.1.2/lib/ruby/gems/2.1.0/extensions


CMD /home/init.sh
USER 21000
GROUP 999