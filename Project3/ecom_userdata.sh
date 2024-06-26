#!/bin/bash

sudo yum update -y
sudo yum install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
sudo echo "<h1>Hello from Terraform! Welcome. This is the final Terraform Project! Congrats.</h1>" >/var/www/html/index.html
