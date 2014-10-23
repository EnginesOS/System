FROM enginesos/servicebase
RUN echo "Y" | adduser -q --disabled-password -uid 22007 volmgr
VOLUME /fs/

ENV ContUser volmgr
ENV ContGrp volmgr

ADD home /home
