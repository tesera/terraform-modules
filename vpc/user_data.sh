#!/usr/bin/env bash

echo "***** Instance ENV *****"
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
INSTANCE_ID=$(curl -s -m 60 http://169.254.169.254/latest/meta-data/instance-id)

echo "***** Update *****"
yum update -y
pip install --upgrade awscli

echo "***** Setup Networking Route Table *****"
aws ec2 --region $REGION delete-route --destination-cidr-block 0.0.0.0/0 --route-table-id ${ROUTE_TABLE_ID}
aws ec2 --region $REGION delete-route --destination-cidr-block ::/0 --route-table-id ${ROUTE_TABLE_ID}
aws ec2 --region $REGION create-route --destination-cidr-block 0.0.0.0/0 --route-table-id ${ROUTE_TABLE_ID} --instance-id $INSTANCE_ID
aws ec2 --region $REGION create-route --destination-cidr-block ::/0 --route-table-id ${ROUTE_TABLE_ID} --instance-id $INSTANCE_ID
