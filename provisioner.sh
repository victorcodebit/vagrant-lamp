#!/usr/bin/env bash

echo -e "Installing packages. This might take a couple of minutes."
echo -e "Installing \e[0;94mApache\e[0m, \e[0;94mPHP\e[0m and \e[0;94mMySQL\e[0m..."

# Fetch updates
apt-get update

# Upgrade all installed packages
apt-get upgrade

# Install Apache
apt-get install -y apache2

# Change the default apache user
sed -i "s/www-data/vagrant/g" /etc/apache2/envvars

# Change the default apache log user
chown -R vagrant:vagrant /var/log/apache2

# Change the VirtualHost
echo "<VirtualHost *:80>
    #ServerName www.example.com
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html

    <Directory /var/www/html>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog /error.log
    CustomLog /access.log combined
</VirtualHost>" > /etc/apache2/sites-available/000-default.conf

# Enabling mod_rewrite
a2enmod rewrite

# Reload Apache
service apache2 reload

# Install MySql
echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections
apt-get install -y mysql-server

# Change the mysql bind-address
sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

# Grant access to a database user
echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION" | mysql --user=root --password=root
echo "GRANT PROXY ON ''@'' TO 'root'@'%' WITH GRANT OPTION" | mysql --user=root --password=root

# Restart MySql
service mysql restart

# Install PHP
apt-get install -y php libapache2-mod-php php-mysql

# Reload Apache
service apache2 reload

# Remove packages that were installed by other packages and are no longer needed
apt-get autoremove -y

echo -e "\e[0;92mDevelopment server started successfully!\e[0m"
echo -e "* Local: http://localhost:8080"
echo -e "* MySQL: mysql --host=localhost --port=13306 --user=root --password=root"