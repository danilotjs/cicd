FROM docker.io/amazoncorretto@sha256:a8be1025fc9e8de39487130162c043523ffa7899320405b11f84632d7c60d1e8
LABEL maintainer "Danilo"
RUN yum -y install httpd
RUN yum -y install php
CMD /usr/sbin/httpd -D FOREGROUND
WORKDIR /var/www/html
COPY index.html /var/www/html
EXPOSE 80
