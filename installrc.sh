#!/bin/bash

WORK_DIR="/remoteconnect"
DOWNLOAD_SERVER="rc.lundmarks.net"

JAR="generic-customize-extension.jar"
SERVER="guacamole-server-0.9.12-incubating"
CLIENT="guacamole-client-0.9.12-incubating"
LDAP="guacamole-auth-ldap-0.9.12-incubating"
WAR="guacamole.war"
XML="server.xml"
TOMCAT_PORT=$1
IP=/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'


if [[ -n "$TOMCAT_PORT" ]] ;
        then



LIST_OF_APPS="build-essential default-jdk htop locate tomcat7 maven libcairo2-dev \
	 libjpeg62-turbo-dev libpng12-dev libossp-uuid-dev libavcodec-dev \
	 libavutil-dev libswscale-dev libfreerdp-dev libpango1.0-dev \
	 libssh2-1-dev libtelnet-dev libvncserver-dev libpulse-dev libssl-dev \
	 libvorbis-dev libwebp-dev"



apt-get update -y

apt-get install -y --no-install-recommends $LIST_OF_APPS


mkdir $WORK_DIR

cd $WORK_DIR

wget http://$DOWNLOAD_SERVER/$JAR
wget http://$DOWNLOAD_SERVER/$SERVER.tar.gz
wget http://$DOWNLOAD_SERVER/$CLIENT.tar.gz
wget http://$DOWNLOAD_SERVER/$LDAP.tar.gz
wget http://$DOWNLOAD_SERVER/$XML
wget http://$DOWNLOAD_SERVER/$WAR


sed -i 's/8080/'"$TOMCAT_PORT"'/' /remoteconnect/server.xml


tar -xzf $SERVER.tar.gz
tar -xzf $CLIENT.tar.gz
tar -xzf $LDAP.tar.gz

rm $SERVER.tar.gz
rm $CLIENT.tar.gz
rm $LDAP.tar.gz

cd $SERVER

./configure --with-init-dir=/etc/init.d

make

make install

ldconfig

cd $WORK_DIR/$CLIENT

#mvn package

#cp ./guacamole/target/guacamole-0.9.10-incubating.war /var/lib/tomcat7/webapps/guacamole.war

cp $WORK_DIR/$WAR /var/lib/tomcat7/webapps/


mkdir /usr/lib/x86_64-linux-gnu/freerdp

cp /usr/local/lib/freerdp/guacdr-client.so /usr/lib/x86_64-linux-gnu/freerdp/
cp /usr/local/lib/freerdp/guacsnd-client.so /usr/lib/x86_64-linux-gnu/freerdp/


mkdir /usr/share/tomcat7/.guacamole/
mkdir /usr/share/tomcat7/.guacamole/extensions

cp $WORK_DIR/$JAR /usr/share/tomcat7/.guacamole/extensions
cp $WORK_DIR/$XML /etc/tomcat7/$XML

echo 'guacd-host: localhost' > /usr/share/tomcat7/.guacamole/guacamole.properties
echo 'guacd-port: 4822' >> /usr/share/tomcat7/.guacamole/guacamole.properties
echo '' >> /usr/share/tomcat7/.guacamole/guacamole.properties
echo '' >> /usr/share/tomcat7/.guacamole/guacamole.properties
echo 'user-mapping: /usr/share/tomcat7/.guacamole/user-mapping.xml' >> /usr/share/tomcat7/.guacamole/guacamole.properties



touch /usr/share/tomcat7/.guacamole/user-mapping.xml
/etc/init.d/tomcat7 restart
/etc/init.d/guacd start





clear

echo 'Do not forget to fill in the user-mapping.xml files located in /usr/share/tomcat7/.guacamole/ '
echo 'Once that is done you can direct your browser to http://'"$IP:$TOMCAT_PORT"


else
         echo 'Please supply a port number as an argument after the script name (ie.. installrc.sh 1301). '
         exit 1

fi

