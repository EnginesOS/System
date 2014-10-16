FROM  enginesos/rails4

RUN /usr/sbin/addgroup --gid 999 docker
RUN echo "Y" | adduser -q --uid 21000 --gid 999 --home /home/dockuser --disabled-password dockuser

ADD home home
ADD profile /home/dockuser/.profile

ADD ssh /home/dockuser/.ssh

ENV ContUser dockuser
ENV ContGrp ruby

RUN chown -R dockuser /home/app/ ; useradd -G ruby dockuser

#RUN echo ".  /etc/rvmrc " >> /root/.profile
#RUN echo "rvm  --default use ruby-2.1.2" >> /root/.profile

RUN cp -rp  ~/.gemrc ~/.rbenv ~/.bashrc ~dockuser

ADD mgmt.pub /home/dockuser/.ssh/authorized_keys
RUN chown -R dockuser /home/dockuser/
RUN chmod -R  700 /home/dockuser/.ssh

EXPOSE 80
EXPOSE 22

