echo "***** Instance ENV *****"
INSTANCE_ID=$(curl -s -m 60 http://169.254.169.254/latest/meta-data/instance-id)
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
REGION=$(echo $AVAILABILITY_ZONE | sed 's/.$//')

echo "***** Attach IP [Public Subnet Only] *****"
aws --region $REGION ec2 associate-address --instance-id $INSTANCE_ID --allocation-id ${EIP_ID}

echo "***** Setup SSH via IAM *****"
cat << EOF > /etc/aws-ec2-ssh.conf
IAM_AUTHORIZED_GROUPS="${IAM_AUTHORIZED_GROUPS}"
SUDOERS_GROUPS="${SUDOERS_GROUPS}"
ASSUMEROLE="${ASSUMEROLE}"
EOF

/usr/bin/import_users.sh
