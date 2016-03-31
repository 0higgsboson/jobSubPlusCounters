#!/bin/bash

# After installation is complete, Open
# vi /etc/mongod.conf
# and comment out the following line
#  bindIp: 127.0.0.1
# service mongod restart

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927

# For Ubuntu 12.04
echo "deb http://repo.mongodb.org/apt/ubuntu precise/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

# For Ubuntu 14.04
#echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

sudo apt-get update
sudo apt-get install -y mongodb-org
sudo service mongod start

curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-get install -y build-essential

npm install -g mongo-express
cp /usr/lib/node_modules/mongo-express/config.default.js /usr/lib/node_modules/mongo-express/config.js
npm install forever -g
forever start /usr/lib/node_modules/mongo-express/app.js

export LC_ALL=C
echo "export LC_ALL=C" >> /etc/environment


