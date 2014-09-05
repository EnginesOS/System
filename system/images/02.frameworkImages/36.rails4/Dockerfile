FROM  enginesos/ruby2.1.1


RUN gem install rails
RUN gem install mysql2
RUN apt-get -y  libxslt-dev libxml2-dev
RUN gem install nokogiri -- --use-system-libraries

#shouldn't need to be here as in ruby 2.1.1 but here to sort out why 
ENV ContUser ruby