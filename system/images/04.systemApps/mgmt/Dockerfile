FROM  enginesos/rails4

RUN /usr/sbin/addgroup --gid 999 docker
RUN echo "Y" | adduser -q --uid 1001 --gid 999 --home /home/dockuser --disabled-password dockuser
ADD home home
ADD profile /home/dockuser/.profile
ADD ssh /home/dockuser/.ssh

ADD mgmt.pub /home/dockuser/.ssh/authorized_keys
RUN chown -R dockuser /home/dockuser/.ssh





EXPOSE 80
EXPOSE 22

