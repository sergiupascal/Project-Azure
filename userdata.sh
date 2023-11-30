#!/bin/bash

# Disable SELinux
sudo getenforce
sudo setenforce 0

# Install Apache
sudo yum install httpd mysql -y
sudo systemctl start httpd
sudo systemctl enable httpd

# Install WGET and Unzip
sudo yum install wget unzip -y

# Download and extract website template
wget https://www.free-css.com/assets/files/free-css-templates/download/page296/little-fashion.zip
unzip little-fashion.zip
mv 2127_little_fashion/*   /var/www/html/


# Install PHP 7.3
sudo yum install epel-release yum-utils -y
sudo yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
sudo yum-config-manager --enable remi-php73
sudo yum install php php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo -y
sudo systemctl restart httpd

# Install Wordpress
sudo wget https://en-gb.wordpress.org/latest-en_GB.tar.gz 
sudo tar -xf latest-en_GB.tar.gz 
sudo rm -rf /var/www/html/* 
sudo mv wordpress/* /var/www/html/ 
sudo chown -R  apache:apache  /var/www/html 
sudo yum install php-mysqli -y 
sudo systemctl restart httpd 

# Install MYSQL Maria DB Server 
sudo yum install mariadb mariadb-server -y 
sudo systemctl start mariadb  
sudo systemctl enable mariadb 
sudo mysql_secure_installation  

# Configure wp-config.php with the database details
sed -i -e "s/database_name_here/project-db/" /var/www/html/wp-config.php
sed -i -e "s/username_here/mysqladmin/" /var/www/html/wp-config.php
sed -i -e "s/password_here/H@ShiCORP!/" /var/www/html/wp-config.php