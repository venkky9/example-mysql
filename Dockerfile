FROM openjdk:7-jdk
MAINTAINER Manuel de la Peña <manuel.delapenya@liferay.com>

ENV DEBIAN_FRONTEND noninteractive
ENV TOMCAT_MAJOR_VERSION=8
ENV TOMCAT_VERSION=8.5.57
ENV TOMCAT_HOME=/opt/apache-tomcat-$TOMCAT_VERSION

# Prepare the installation of mysql-server and tomcat 7
RUN apt-get update && apt-get install -y lsb-release && \
  wget https://dev.mysql.com/get/mysql-apt-config_0.8.4-1_all.deb && \
  dpkg -i mysql-apt-config_0.8.4-1_all.deb && rm -f mysql-apt-config_0.8.4-1_all.deb && \
  mkdir -p $TOMCAT_HOME && cd /opt && \
  wget https://mirrors.estointernet.in/apache/tomcat/tomcat-$TOMCAT_MAJOR_VERSION/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz && \
  tar -xvf apache-tomcat-$TOMCAT_VERSION.tar.gz && rm -f apache-tomcat-$TOMCAT_VERSION.tar.gz

# Install packages
RUN apt-get -y install pwgen python-setuptools curl git nano sudo unzip openssh-server openssl vim htop
RUN apt-get -y install php7.4-fpm php7.4-common php7.4-mysql php7.4-xml php7.4-xmlrpc php7.4-curl php7.4-gd php7.4-imagick php7.4-cli php7.4-dev php7.4-imap php7.4-mbstring php7.4-soap php7.4-zip php7.4-bcmath php7.4-memcache php7.4-mysql
RUN apt-get -y install mysql-server-5.6 mysql-client-5.6 nginx
RUN apt-get install -y supervisor && \
    rm -rf /var/lib/apt/lists/*

# Add image configuration and scripts
ADD start-tomcat.sh /start-tomcat.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
RUN chmod 644 /etc/mysql/conf.d/my.cnf
ADD supervisord-tomcat.conf /etc/supervisor/conf.d/supervisord-tomcat.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
ADD mysql-setup.sh /mysql-setup.sh
RUN chmod 755 /*.sh

WORKDIR $TOMCAT_HOME

# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql"]

EXPOSE 8080 3306

ENTRYPOINT ["/run.sh"]
