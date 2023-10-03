#!/bin/bash
sudo echo "apache installation....."
sudo apt-get update
sudo apt-get install apache2 -y

echo "test file creation ...."
sudo mkdir /home/ubuntu/demo-test.txt

git clone https://github.com/amolshete/card-website.git

cp -rf card-website/* /var/www/html/