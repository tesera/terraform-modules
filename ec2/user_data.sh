#!/usr/bin/env bash

echo "***** Instance ENV *****"
INSTANCE_ID=$(curl -s -m 60 http://169.254.169.254/latest/meta-data/instance-id)

echo "***** Update *****"
yum update -y
pip install --upgrade awscli

${USER_DATA}

echo "***** Clean Up *****"
