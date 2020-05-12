#!/bin/bash
yum update -y
yum install httpd -y
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`  # returns internal ip address

cat <<EOF > /var/www/html/index.html
<html>
<h2>Web-server $site_name $site_ver v3.2 with IP $myip</h2><br>
EOF
sudo service httpd start
sudo chkconfig httpd on
