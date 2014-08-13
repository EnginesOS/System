FROM  raspberry/base
RUN apt-get -y install patch bzip2 gawk g++ gcc make libc6-dev patch libreadline6-dev zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev 
RUN \curl -L https://get.rvm.io | bash -s stable
RUN /usr/local/rvm/bin/rvm install ruby-1.9

ENV GEM_HOME /usr/local/rvm/gems/ruby-1.9.3-p547
ENV GEM_PATH /usr/local/rvm/gems/ruby-1.9.3-p547:/usr/local/rvm/gems/ruby-1.9.3-p547@global
ENV MY_RUBY_HOME /usr/local/rvm/rubies/ruby-1.9.3-p547
ENV RUBY_VERSION ruby-1.9.3-p547
ENV RPATH /usr/local/rvm/gems/ruby-1.9.3-p547/bin:/usr/local/rvm/gems/ruby-1.9.3-p547@global/bin:/usr/local/rvm/rubies/ruby-1.9.3-p547/bin:/usr/local/rvm/bin
ENV PATH /usr/local/rvm/gems/ruby-1.9.3-p547/bin:/usr/local/rvm/gems/ruby-1.9.3-p547@global/bin:/usr/local/rvm/rubies/ruby-1.9.3-p547/bin:/usr/local/rvm/bin:/usr/bin/:/bin:/bin:/sbin/:/usr/sbin


RUN gem install rake
RUN gem install bundle
