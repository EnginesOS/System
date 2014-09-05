FROM  enginesos/ruby19


RUN gem install rails --version 3.2.19
RUN gem install mysql2
RUN apt-get -y  libxslt-dev libxml2-dev
RUN gem install nokogiri -- --use-system-libraries
