FROM  enginesos/ruby2.1.2

ADD Gems /home/
RUN ~/.rbenv/shims/gem install `cat /home/Gems` ;  ~/.rbenv/bin/rbenv rehash
RUN chmod -R g+w /.rbenv ;chgrp -R ruby /.rbenv


