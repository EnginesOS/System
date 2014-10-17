FROM  enginesos/base

RUN apt-get update
RUN apt-get install -y git-core python python-dev python-lxml
ADD home home
ENV ContUser www-data
ENV ContGrp www-data