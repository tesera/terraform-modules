#!/usr/bin/env bash

echo "***** Instance ENV *****"
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
INSTANCE_ID=$(curl -s -m 60 http://169.254.169.254/latest/meta-data/instance-id)

echo "***** Update *****"
yum update -y
pip install --upgrade awscli
#yum install epel-release -y

echo "***** Setup Banner *****"
yum install figlet -y
BANNER=$(figlet "${BANNER}" | sed "s/\`/\'/")
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
sed -i "s/{instance_id}/$INSTANCE_ID/" /etc/awslogs/awslogs.conf
service awslogs start

echo "***** Setup fail2ban *****"
yum install fail2ban -y
service fail2ban start

echo "***** Setup SSH via IAM *****"
rpm -i https://s3-eu-west-1.amazonaws.com/widdix-aws-ec2-ssh-releases-eu-west-1/aws-ec2-ssh-1.9.1-1.el7.centos.noarch.rpm
cat << EOF > /etc/aws-ec2-ssh.conf
IAM_AUTHORIZED_GROUPS="${IAM_AUTHORIZED_GROUPS}"
SUDOERS_GROUPS="${SUDOERS_GROUPS}"
LOCAL_GROUPS="${LOCAL_GROUPS}"
EOF

/usr/bin/import_users.sh

##############################

echo "***** Disabling Source/Destination Checks *****"
aws ec2 --region $REGION modify-instance-attribute --no-source-dest-check --instance-id $INSTANCE_ID

echo "***** Setup Networking Route Table *****"
aws ec2 --region $REGION delete-route --destination-cidr-block 0.0.0.0/0 --route-table-id ${ROUTE_TABLE_ID}
aws ec2 --region $REGION create-route --destination-cidr-block 0.0.0.0/0 --route-table-id ${ROUTE_TABLE_ID} --instance-id $INSTANCE_ID

echo "***** Setup Auto-Tuning *****"
# https://aws.amazon.com/premiumsupport/knowledge-center/vpc-nat-instance/
# For larger instances only
# error: "net.ipv4.netfilter.ip_conntrack_max" is an unknown key
cat << EOF > /etc/sysctl.d/custom_nat_tuning.conf
# for large instance types, allow keeping track of more
# connections (requires enough RAM)
net.ipv4.netfilter.ip_conntrack_max=262144
EOF
sysctl -p /etc/sysctl.d/custom_nat_tuning.conf
