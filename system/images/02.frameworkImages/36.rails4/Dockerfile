FROM  enginesos/ruby2.1.2

ADD Gems /home/
RUN /usr/local/rbenv/shims/gem install `cat /home/Gems` 
RUN  rbenv rehash
#RUN chmod -R g+w ~/.rbenv ;chgrp -R ruby ~/.rbenv


