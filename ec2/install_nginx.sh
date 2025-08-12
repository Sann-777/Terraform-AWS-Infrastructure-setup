#!/bin/bash

sudo apt-get update
sudo apt-get install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

echo "<h1> Automated this simple nginx server using Terraform </h1>" | sudo tee /var/www/html/index.html