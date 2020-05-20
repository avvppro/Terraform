
======== gb-deploy: ========
 v1.1
 - green-blue-deployment using custom vpc, public subnets, internet gateway, autoscaling group, classic load balancer.
 - works in two aviliability zones of ANY REGION

======== modules: ==========
 v1.0
 - /aws_network        add module which creates public and private(NAT) networks  
 v1.1
 - /aws_security_group add module which creates security groups
 - /aws_network        variable names fix

======== pro1/dev: =========
 v1.0
 - /network            create network using module aws_network
 v1.1
 - /network            add backend to s3  avvppro-terraform.tfstate-bucket
 - /security_group     add security group vs allowed ports
