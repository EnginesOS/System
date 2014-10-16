FROM  enginesos/base
RUN   apt-get -y update ;
RUN apt-get -y install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libmagickcore-dev libmagickwand-dev

RUN mkdir ~/node_js_src && cd $_;wget -N http://nodejs.org/dist/node-latest.tar.gz;tar xzvf node-latest.tar.gz && cd node-v*;./configure; make ;make install

ENV ContUser ruby

RUN echo "Y" | adduser -q  --home /home/ruby --disabled-password ruby
RUN cd ~ ; git clone git://github.com/sstephenson/rbenv.git .rbenv
RUN cd ~ ; git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
RUN cd ~   ;echo 'export PATH="/.rbenv/bin:$PATH"' >> ~/.bashrc ; echo 'eval "$(rbenv init -)"' >> ~/.bashrc ; exec $SHELL ; ~/.rbenv/bin/rbenv install 2.1.2 ; ~/.rbenv/bin/rbenv global 2.1.2
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc
RUN   ~/.rbenv/shims/gem install rails
RUN ~/.rbenv/bin/rbenv rehash
RUN cp -rp  ~/.gemrc ~/.rbenv ~/.bashrc ~ruby
