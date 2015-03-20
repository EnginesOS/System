FROM engines/ruby19:$release


RUN gem install rails --version 3.2.19
RUN gem install mysql2
RUN apt-get -y install  libxslt-dev libxml2-dev
RUN gem install nokogiri -- --use-system-libraries
