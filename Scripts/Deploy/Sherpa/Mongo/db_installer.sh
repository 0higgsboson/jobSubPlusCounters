#!/bin/bash

#Notes
# After installation is complete, Open
# vi /etc/mongod.conf
# and comment out the following line
# bindIp: 127.0.0.1
# Restart Mongo Db
# service mongod restart

# change hostname in /usr/lib/node_modules/mongo-express/config.js from localhost to hostname to access it from outside
# for Mongo Express please find the following line under 'site'
#    host:             process.env.VCAP_APP_HOST                 || 'locahost',
#    and change it to
#    host:             process.env.VCAP_APP_HOST                 || 'hostname',




if [ ! -f  "/etc/redhat-release" ];
then

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



else

echo "[mongodb-org-3.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/3.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.2.asc" > /etc/yum.repos.d/mongodb-org-3.2.repo

sudo yum install -y mongodb-org
mkdir -p /data/db
#sudo service mongod start

sed -i "s~bindIp: 127.0.0.1~#bindIp: 127.0.0.1~" /etc/mongod.conf
mongod --fork --logpath mongo.log

fi



