FROM  enginesos/rails4

RUN /usr/sbin/addgroup --gid 999 docker
RUN echo "Y" | adduser -q --uid 21000 --gid 999 --home /home/dockuser --disabled-password dockuser
ADD home home
ADD profile /home/dockuser/.profile
ADD ssh /home/dockuser/.ssh
ENV ContUser dockuser
ADD mgmt.pub /home/dockuser/.ssh/authorized_keys
RUN chown -R dockuser /home/dockuser/
RUN chown -R dockuser /home/app/
RUN echo ".  /etc/rvmrc " >> /root/.profile
RUN echo "rvm  --default use ruby-2.1.2" >> /root/.profile



EXPOSE 80
EXPOSE 22

