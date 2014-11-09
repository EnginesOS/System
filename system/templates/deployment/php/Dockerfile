FROM  engines/php
ADD home home
ADD engines home/engines
ADD cron/ /etc/cron.d
CMD /usr/sbin/apache2ctl -D FOREGROUND

CMD usermod  -s /bin/bash $ContUser

