FROM engines/frameworkbase

RUN echo "Y" | adduser -q --uid 22674 --home /home/python --disabled-password python
RUN apt-get update -y
RUN apt-get install -y  python python-dev python-lxml

ADD home home
ENV ContUser python
ENV ContGrp python