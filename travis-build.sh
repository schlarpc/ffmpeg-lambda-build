#!/bin/sh

sudo apt-get update
sudo apt-get -y install python-pip
sudo pip install awscli
aws ecr get-login --region us-west-2 --registry-ids 137112412989
