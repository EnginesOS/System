FROM  enginesos/base
RUN apt-get -y install patch bzip2 gawk g++ gcc make libc6-dev libreadline6-dev zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev 
RUN \curl -L https://get.rvm.io | bash -s stable
RUN /usr/local/rvm/bin/rvm install ruby-2.1.2

RUN /usr/local/rvm/bin/rvm  --default use ruby-2.1.2
ENV MY_RUBY_HOME /usr/local/rvm/rubies/ruby-2.1.2
ENV rvm_ruby_string ruby-2.1.2
ENV IRBRC /usr/local/rvm/rubies/ruby-2.1.2/.irbrc
ENV GEM_HOME /usr/local/rvm/gems/ruby-2.1.2
ENV GEM_PATH /usr/local/rvm/gems/ruby-2.1.2:/usr/local/rvm/gems/ruby-2.1.2@global
ENV rvm_delete_flag 0
ENV RUBY_VERSION ruby-2.1.2
ENV RPATH /usr/local/rvm/gems/ruby-2.1.2/bin:/usr/local/rvm/gems/ruby-2.1.2@global/bin:/usr/local/rvm/rubies/ruby-2.1.2/bin:/usr/local/rvm/bin:
ENV PATH /usr/local/rvm/gems/ruby-2.1.2/bin:/usr/local/rvm/gems/ruby-2.1.2@global/bin:/usr/local/rvm/rubies/ruby-2.1.2/bin:/usr/local/rvm/bin:/usr/local/bin:/usr/bin:/bin:/sbin/:/usr/sbin


RUN /usr/local/rvm/rubies/ruby-2.1.2/bin/gem install rake
RUN /usr/local/rvm/rubies/ruby-2.1.2/bin/gem install bundle
ENV ContUser ruby


RUN echo "Y" | adduser -q  --home /home/ruby --disabled-password ruby
RUN echo ".  /etc/rvmrc " >> /home/ruby/.profile
RUN echo "rvm  --default use ruby-2.1.2" >> /home/ruby/.profile