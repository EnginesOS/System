FROM enginesos/frameworkbase


RUN apt-get install -y  python python-dev python-lxml
RUN mkdir ~/node_js_src && cd $_;wget -N http://nodejs.org/dist/node-latest.tar.gz;tar xzvf node-latest.tar.gz && cd node-v*;./configure; make ;make install
ADD home home
ENV ContUser www-data
ENV ContGrp www-data