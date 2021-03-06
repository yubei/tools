#!/usr/bin/env bash
echo '确认已经添加/usr/local/bin 到PATH环境变量?[y/n]';
read in
if [ $in != 'y' ]
then
    echo 'Cancle ... '
    exit
fi
PHPVERSION='7.0.5'
NGINXVERSION='1.9.15'

useradd www

mkdir lnmp
cd lnmp
ROOTPATH=`pwd`
wget http://sg3.php.net/distributions/php-${PHPVERSION}.tar.gz -O php-${PHPVERSION}.tar.gz
tar -zxvf php-${PHPVERSION}.tar.gz
wget http://nginx.org/download/nginx-${NGINXVERSION}.tar.gz -O nginx-${NGINXVERSION}.tar.gz
tar -zxvf nginx-${NGINXVERSION}.tar.gz
wget https://github.com/h5bp/server-configs-nginx/archive/master.zip -O server-configs-nginx-master.zip
unzip server-configs-nginx-master.zip
wget http://repo.mysql.com//mysql57-community-release-el6-8.noarch.rpm


# ----------------------------------
#           Install PHP
# ----------------------------------

yum update -y
#update automake
yum -y install libxml2 libxml2-devel openssl openssl-devel curl-devel libjpeg-devel libpng-devel freetype-devel libmcrypt-devel
#pdo-unicodbc
yum -y install unixODBC-devel
#openssl snmp
yum -y install net-snmp-devel

cd $ROOTPATH/php-$PHPVERSION
bash $ROOTPATH/install-php.sh
make
make install

cp $ROOTPATH/php-$PHPVERSION/php.ini-production  /etc/php/$PHPVERSION/php.ini
mv /etc/php/$PHPVERSION/php-fpm.conf.default /etc/php/$PHPVERSION/php-fpm.conf
mv /etc/php/$PHPVERSION/php-fpm.d/www.conf.default /etc/php/$PHPVERSION/php-fpm.d/www.conf

cd /usr/local/bin
ln -s /usr/local/php/$PHPVERSION/bin/pear pear
ln -s /usr/local/php/$PHPVERSION/bin/pecl pecl
ln -s /usr/local/php/$PHPVERSION/bin/phar phar
ln -s /usr/local/php/$PHPVERSION/bin/php php
ln -s /usr/local/php/$PHPVERSION/bin/php-cgi php-cgi
ln -s /usr/local/php/$PHPVERSION/bin/php-config php-config
ln -s /usr/local/php/$PHPVERSION/bin/phpize phpize
ln -s /usr/local/php/$PHPVERSION/bin/phpdbg phpdbg

cd /usr/local/sbin
ln -s /usr/local/php/$PHPVERSION/sbin/php-fpm php-fpm

# ----------------------------------
#           Install Nginx
# ----------------------------------


cd $ROOTPATH/nginx-$NGINXVERSION
bash $ROOTPATH/install-nginx.sh
cp -r $ROOTPATH/server-configs-nginx-master/* /usr/local/nginx/


# ----------------------------------
#           Install Mysql
# https://www.digitalocean.com/community/tutorials/how-to-install-mysql-5-6-from-official-yum-repositories
# ----------------------------------
yum -y remove mysql.x86_64
yum -y remove mysql-libs.x86_64
yum localinstall mysql57-community-release-el6-8.noarch.rpm
yum -y install mysql-community-server
chkconfig mysqld on
