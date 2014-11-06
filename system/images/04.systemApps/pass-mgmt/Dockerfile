FROM  engines/passenger

RUN /usr/sbin/addgroup --gid 999 docker
RUN echo "Y" | adduser -q --uid 21000 --gid 999 --home /home/dockuser --disabled-password dockuser

ADD home home
ADD profile /home/dockuser/.profile


ENV ContUser dockuser
ENV ContGrp ruby

RUN chown -R dockuser /home/app/ ; usermod -G ruby -a dockuser


CMD /home/init.sh
USER 21000
GROUP 999