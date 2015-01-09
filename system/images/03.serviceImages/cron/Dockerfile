FROM  engines/servicebase
RUN echo "Y" | adduser -q --disabled-password --home /var/cache/bind -uid 21000 dockuser

COPY home home


CMD /home/init.sh