FROM  enginesos/ruby2.1.2

ADD Gems /home/
RUN /usr/local/rbenv/shims/gem  install `cat /home/Gems` 
RUN  /usr/local/rbenv/bin/rbenv rehash
RUN chmod -R g+w /usr/local/rbenv/versions/ ;chgrp -R ruby /usr/local/rbenv/versions/



