#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Wait for Internet access through the FGTs"
while ! curl --connect-timeout 3 "http://www.google.com" &> /dev/null
    do continue
done
apt-get update -y
#install apache2
apt-get install -y apache2
cd /var/www/html
base64 /dev/urandom | head -c 32768 > 32KB.txt
base64 /dev/urandom | head -c 45056 > 44KB.txt
base64 /dev/urandom | head -c 65536 > 64KB.txt
base64 /dev/urandom | head -c 131072 > 128KB.txt
a2enmod ssl
service apache2 restart
a2ensite default-ssl.conf
a2disconf other-vhosts-access-log
sed -i 's/#*[Cc]ustom[Ll]og/#CustomLog/g' /etc/apache2/sites-enabled/*
sed -i 's/#*[Ee]rror[Ll]og/#ErrorLog/g' /etc/apache2/sites-enabled/*
sed -i 's/KeepAlive On/KeepAlive Off/g' /etc/apache2/apache2.conf
service apache2 reload
#install iperf
apt-get install -y iperf
#install iperf3
apt-get install -y iperf3
iperf3 --server --daemon --logfile /var/log/iperf3.txt --pidfile /run/iperf3.pid