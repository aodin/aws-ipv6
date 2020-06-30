#!/bin/bash

# Add any commands that should be run on instance creation
sudo apt install nginx -y -q
sudo service nginx start
