FROM stackbrew/ubuntu:12.04
MAINTAINER Lucas Carlson <lucas@rufy.com>

RUN apt-get update -qq && apt-get install -y mysql-server-5.5

ADD my.cnf /etc/mysql/conf.d/my.cnf
RUN chmod 664 /etc/mysql/conf.d/my.cnf
ADD run.sh /run.sh
RUN chmod +x /run.sh

VOLUME ["/var/lib/mysql"]
EXPOSE 3306

RUN mkdir -p /go
ENV PATH /usr/local/go/bin:/go/bin:$PATH
ENV GOROOT /usr/local/go
ENV GOPATH /go

RUN apt-get update && apt-get install --yes --force-yes curl git mercurial zip wget ca-certificates build-essential
RUN apt-get install -yq vim sudo

RUN curl -s https://go.googlecode.com/files/go1.2.1.src.tar.gz | tar -v -C /usr/local -xz
RUN cd /usr/local/go/src && ./make.bash --no-clean 2>&1

RUN go get -u -d github.com/beego/redigo/redis
RUN go get -u -d github.com/gogits/gogs 
RUN cd $GOPATH/src/github.com/gogits/gogs && git checkout dev && git pull origin dev && go install && go build -tags redis

# Clean all the unused packages
RUN apt-get autoremove -y
RUN apt-get clean all

ADD app.ini $GOPATH/src/github.com/gogits/gogs/custom/conf/app.ini

ENV MYSQL_DATABASE gogs
ENV MYSQL_ROOT_PASSWORD kfd9kiewLdk
ENV INSTALLED false
ENV USER root

EXPOSE 3000

CMD ["/run.sh"]
