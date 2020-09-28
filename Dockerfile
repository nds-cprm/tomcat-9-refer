#FROM openjdk:11-jdk-slim-buster
# this is the local tunned image from debian:buster-slim plus gosu, procps, libnss-wrapper
# already have /docker-entrypoint.sh and /docker-entrypoint.d
FROM openjdk:11

ENV JAVA_HOME /usr/lib/java
ENV CATALINA_HOME /usr/local/tomcat
ENV CATALINA_BASE /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
ENV LD_LIBRARY_PATH $CATALINA_HOME/lib:$LD_LIBRARY_PATH

# use site default packages
ENV VERSION 9.0.38

RUN set -eux; \
# include extras
    apt update ; \
    apt install -y --no-install-recommends wget ; \
# get from site and check
    wget -v https://downloads.apache.org/tomcat/tomcat-9/v${VERSION}/bin/apache-tomcat-${VERSION}.tar.gz ; \
    wget -v https://downloads.apache.org/tomcat/tomcat-9/v${VERSION}/bin/apache-tomcat-${VERSION}.tar.gz.sha512 ; \
    if ! sha512sum -c apache-tomcat-${VERSION}.tar.gz.sha512 ; \
        then echo "bad download" && exit 1 ; \
        fi ; \
    tar -zxvf apache-tomcat-${VERSION}.tar.gz -C /usr/local/ ; \
    rm apache-tomcat-${VERSION}.tar.gz apache-tomcat-${VERSION}.tar.gz.sha512 ; \
# simplifiy
    ln -s /usr/local/apache-tomcat-${VERSION} /usr/local/tomcat ; \
# hide original
    mv /usr/local/tomcat/webapps /usr/local/tomcat/webapps.dist ; \
    mkdir -p /usr/local/tomcat/webapps ; \
    chmod 755 /usr/local/tomcat/webapps ; \
# exclude extras
    apt remove -y wget ; \
    rm -rf /var/lib/apt/lists/* ; 

# the following  message in logs is normal because no want provide any SSL or https for tomcat
# The Apache Tomcat Native library which allows using OpenSSL was not found on the java.library.path:
# must be done by a proxy. see
# https://www.digitalocean.com/community/tutorials/how-to-encrypt-tomcat-8-connections-with-apache-or-nginx-on-ubuntu-16-04

# agsb@2020, sane permissions

RUN set -ex; \
    groupadd -r -g 888 tomcat ; \
    useradd -r -g tomcat -u 888 -s /bin/false -d /usr/local/tomcat tomcat ; \
    for dir in logs work temp try ; do \
        mkdir -p  /usr/local/tomcat/$dir ; \
        chmod 755 /usr/local/tomcat/$dir ; \
        chown -R tomcat.tomcat /usr/local/tomcat/$dir ; \
    done ; 

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["catalina.sh", "run"]

