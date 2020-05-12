#!/bin/bash
yum update -y
yum install httpd -y
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`  # returns internal ip address

cat <<EOF > /var/www/html/index.html
<html>
<h2>Web-server $site_name $site_ver with IP $myip</h2><br>
%{for x in names ~}         # cycle in shell inside EOF
Name is ${x}<br>
%{ endfor ~}
EOF

sudo service httpd start
sudo chkconfig httpd on
