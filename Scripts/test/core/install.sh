#!/usr/bin/env bash

# installs pip
apt-get -y install python-pip

# installs mongodb driver

pip install pymongo
sudo apt-get install build-essential libssl-dev libffi-dev python-dev
pip install cryptography
pip install paramiko