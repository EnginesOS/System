FROM engines/frameworkbase

ENV ContUser python
ENV ContGrp python

RUN echo "Y" | adduser -q --uid 22674 --home /home/python --disabled-password python;\
	apt-get update -y;\
	apt-get install -y  python python-dev python-lxml;\

ADD home home
