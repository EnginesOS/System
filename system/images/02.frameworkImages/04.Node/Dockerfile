FROM enginesos/frameworkbuild


RUN mkdir ~/node_js_src && cd $_;wget -N http://nodejs.org/dist/node-latest.tar.gz;tar xzvf node-latest.tar.gz && cd node-v*;./configure; make ;make install

ENV ContUser node
ENV ContGrp node
ENV 
RUN groupadd node
RUN echo "Y" | adduser -q --ingroup node --home /home/node --disabled-password node
