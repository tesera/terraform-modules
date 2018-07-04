#!/usr/bin/env bash

echo "***** Attach IP [Public Subnet Only] *****"
INSTANCE_ID=$(curl -s -m 60 http://169.254.169.254/latest/meta-data/instance-id)
aws --region ${REGION} ec2 associate-address --instance-id $INSTANCE_ID --allocation-id ${EIP_ID}

echo "***** Update *****"
yum update -y
pip install --upgrade awscli
#yum install epel-release -y

echo "***** Setup Banner *****"
yum install figlet -y
BANNER=$(figlet "Bastion" | sed 's/`/\\`/')
cat << EOF > /etc/update-motd.d/30-banner
cat << MOTD
$BANNER
MOTD
EOF
/usr/sbin/update-motd
cat /etc/motd
yum remove figlet -y

# TODO apply other CIS changes
# or swap out base image for https://aws.amazon.com/marketplace/pp/B078TPXMH2?qid=1530714745994&sr=0-1&ref_=srh_res_product_title

# TODO setup av
# https://www.centosblog.com/how-to-install-clamav-and-configure-daily-scanning-on-centos/

echo "***** Setup CloudWatch Logging *****"
yum install -y awslogs
sed -i 's/{instance_id}/$INSTANCE_ID/' /etc/awslogs/awslogs.conf
service awslogs start

echo "***** Setup fail2ban [Public Subnet Only] *****"
yum install fail2ban -y
service fail2ban start

echo "***** Setup SSH via IAM *****"
rpm -i https://s3-eu-west-1.amazonaws.com/widdix-aws-ec2-ssh-releases-eu-west-1/aws-ec2-ssh-1.9.0-1.el7.centos.noarch.rpm
sed -i 's/IAM_AUTHORIZED_GROUPS=""/IAM_AUTHORIZED_GROUPS="${IAM_AUTHORIZED_GROUPS}"/' /etc/aws-ec2-ssh.conf
sed -i 's/^DONOTSYNC=1/d' /etc/aws-ec2-ssh.conf
/usr/bin/import_users.sh

echo "***** Clean Up *****"

