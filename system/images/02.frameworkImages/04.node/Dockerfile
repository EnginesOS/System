FROM engines/frameworkbuild


RUN mkdir ~/node_js_src && cd $_;wget -N http://nodejs.org/dist/node-latest.tar.gz;tar xzvf node-latest.tar.gz && cd node-v*;./configure; make ;make install

ENV ContUser node
ENV ContGrp node

RUN groupadd node
RUN echo "Y" | adduser --uid 22671 -q --ingroup node --home /home/node --disabled-password node
