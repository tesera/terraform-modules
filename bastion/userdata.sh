#!/usr/bin/env bash

# Attach IP
INSTANCE_ID=$(curl -s -m 60 http://169.254.169.254/latest/meta-data/instance-id)
aws --region ${REGION} ec2 associate-address --instance-id $INSTANCE_ID --allocation-id ${EIP_ID}

SSH_USER=ec2-user

#yum install epel-release -y
#yum install figlet -y

# AWS CLI
#yum install python -y
#pip install --upgrade awscli

# check if AWS CLI exists
#if ! [ -x "$(which aws)" ]; then
#    echo "aws executable not found - exiting!"
#    exit 1
#fi

# Generate system banner
#figlet "Bastion" > /etc/motd

# TODO apply other CIS changes
# or swap out base image for https://aws.amazon.com/marketplace/pp/B078TPXMH2?qid=1530714745994&sr=0-1&ref_=srh_res_product_title

# TODO add awslogs
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/QuickStartEC2Instance.html

# Add in ssh IAM hooks
#rpm -i https://s3-eu-west-1.amazonaws.com/widdix-aws-ec2-ssh-releases-eu-west-1/aws-ec2-ssh-1.9.0-1.el7.centos.noarch.rpm


# Clean Up
#yum uninstall figlet -y
