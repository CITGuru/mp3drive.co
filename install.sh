#!/usr/bin/env bash
set -e

sudo apt-get install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa

sudo apt-get update -y
sudo apt-get upgrade -y

# python

sudo apt-get install -y python3.6 python3.6-dev
sudo apt-get install -y build-essential libssl-dev libffi-dev python3-dev libpq-dev
sudo apt-get install -y python3-pip
sudo -H pip3 install --upgrade pip

sudo -H pip3 install virtualenv
pip3 install virtualenvwrapper

# postgres
sudo apt-get install -y postgresql postgresql-contrib
# nginx
sudo apt-get install -y nginx git-core
pip install awscli --upgrade --user
# mysql
sudo apt-get install mysql-server
sudo apt-get install libmysqlclient-dev