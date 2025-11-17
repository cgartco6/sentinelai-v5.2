#!/bin/bash
sudo apt update
sudo apt install -y nginx php-fpm php-mysql
sudo systemctl enable nginx
sudo systemctl start nginx
sudo systemctl enable php7.4-fpm
sudo systemctl start php7.4-fpm
