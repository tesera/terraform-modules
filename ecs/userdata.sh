#!/usr/bin/env bash

echo "***** Update *****"
yum update -y
pip install --upgrade awscli
#yum install epel-release -y

echo "***** Setup Banner *****"
yum install figlet -y
BANNER=$(figlet "AWS ECS" | sed "s/\`/\'/")
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

echo "***** Setup SSH via IAM *****"
rpm -i https://s3-eu-west-1.amazonaws.com/widdix-aws-ec2-ssh-releases-eu-west-1/aws-ec2-ssh-1.9.0-1.el7.centos.noarch.rpm
cat << EOF > /etc/aws-ec2-ssh.conf
IAM_AUTHORIZED_GROUPS="${IAM_USER_GROUPS}"
SUDOERS_GROUPS="${IAM_SUDO_GROUPS}"
LOCAL_GROUPS="docker"
EOF

/usr/bin/import_users.sh

echo "***** Connect to Cluster *****"
echo ECS_CLUSTER=${ECS_CLUSTER} >> /etc/ecs/ecs.config

echo "***** Clean Up *****"

