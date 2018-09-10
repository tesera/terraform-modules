
echo "***** Attach IP [Public Subnet Only] *****"
aws --region $REGION ec2 associate-address --instance-id $INSTANCE_ID --allocation-id ${EIP_ID}

echo "***** Setup fail2ban [Bastion Only] *****"
yum install fail2ban -y
service fail2ban start

echo "***** Setup OTP [Bastion Only] *****"
# TODO google authenticator - https://github.com/google/google-authenticator-libpam
#rpm -i https://download.fedoraproject.org/pub/fedora/linux/development/rawhide/Everything/source/tree/Packages/g/google-authenticator-1.04-2.fc28.src.rpm
#sed -i 's/auth[\s]+required	pam_sepermit.so/auth	   required pam_google_authenticator.so [authtok_prompt=Your secret token: ]/' /etc/pam.d/sshd
