FROM  enginesos/ruby2.1.1

RUN gem install mysql2
RUN gem install rails

#shouldn't need to be here as in ruby 2.1.1 but here to sort out why 
RUN echo "Y" | adduser -q  --home /home/ruby --disabled-password ruby
RUN echo ".  /etc/rvmrc " >> /home/ruby/.profile

#shouldn't need to be here as in ruby 2.1.1 but here to sort out why 
ENV ContUser ruby