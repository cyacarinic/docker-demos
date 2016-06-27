FROM centos
MAINTAINER Claudio Yacarini <cyacarinic@gmail.com>
RUN mkdir /srv/www
WORKDIR /srv/www
RUN touch test.txt
RUN echo “Hola mundo xD“ >> test.txt
RUN yum install -y epel-release
RUN yum install -y nodejs
RUN node --version
RUN yum install -y npm
RUN npm install http-server -g
