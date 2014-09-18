FROM  enginesos/ruby2.1.2

RUN gem install rails
RUN gem install mysql2
RUN apt-get -y install libxslt-dev libxml2-dev
RUN gem install nokogiri -- --use-system-libraries

ENV ContUser ruby