echo "***** Instance ENV *****"
INSTANCE_TYPE=$(curl -s http://169.254.169.254/latest/meta-data/instance-type)
IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
REGION=$(echo $AVAILABILITY_ZONE | sed 's/.$//')

echo "***** Attach IP [Public Subnet Only] *****"
aws --region $REGION ec2 associate-address --instance-id $INSTANCE_ID --allocation-id ${EIP_ID}

echo "***** Setup OTP [Bastion Only] *****"
# TODO google authenticator - https://github.com/google/google-authenticator-libpam
#rpm -i https://download.fedoraproject.org/pub/fedora/linux/development/rawhide/Everything/source/tree/Packages/g/google-authenticator-1.04-2.fc28.src.rpm
#sed -i 's/auth[\s]+required	pam_sepermit.so/auth	   required pam_google_authenticator.so [authtok_prompt=Your secret token: ]/' /etc/pam.d/sshd

BANNER=$(figlet "${BANNER}" | sed "s/\`/\'/g")
cat << EOF > /etc/update-motd.d/30-banner
cat << MOTD
$BANNER
Private IP:        $IP
Availability Zone: $AVAILABILITY_ZONE
Instance Type:     $INSTANCE_TYPE

MOTD
EOF
/usr/sbin/update-motd
cat /etc/motd

echo "***** Configure CloudWatch Logging *****"
sed -i "s/{instance_id}/$INSTANCE_ID/" /etc/awslogs/awslogs.conf
service awslogsd start

echo "***** Setup SSH via IAM *****"
cat << EOF > /etc/aws-ec2-ssh.conf
IAM_AUTHORIZED_GROUPS="${IAM_AUTHORIZED_GROUPS}"
SUDOERS_GROUPS="${SUDOERS_GROUPS}"
EOF

/usr/bin/import_users.sh
