
echo "***** Attach IP [Public Subnet Only] *****"
aws --region $REGION ec2 associate-address --instance-id $INSTANCE_ID --allocation-id ${EIP_ID}

echo "***** Setup fail2ban [Bastion Only] *****"
yum install fail2ban -y
service fail2ban start

echo "***** Setup OTP [Bastion Only] *****"
# TODO google authenticator - https://github.com/google/google-authenticator-libpam
#rpm -i https://download.fedoraproject.org/pub/fedora/linux/development/rawhide/Everything/source/tree/Packages/g/google-authenticator-1.04-2.fc28.src.rpm
#sed -i 's/auth[\s]+required	pam_sepermit.so/auth	   required pam_google_authenticator.so [authtok_prompt=Your secret token: ]/' /etc/pam.d/sshd

echo "***** PAM Setup ****"

cat << EOF > /usr/bin/pam_verify
#!/usr/bin/env bash
# pam_config Docs: http://www.fis.unipr.it/doc/pam-1.1.1/Linux-PAM_SAG.txt
# pam_exec Docs: http://www.linux-pam.org/Linux-PAM-html/sag-pam_exec.html
# Return Codes: http://pubs.opengroup.org/onlinepubs/8329799/chap5.htm
PAM_SUCCESS=0
PAM_SERVICE_ERR=3
PAM_SYSTEM_ERR=4
PAM_IGNORE=25

function log {
  echo "\$PAM_SERVICE: \$PAM_TTY \$PAM_TYPE \$PAM_USER:\$PAM_OTP@\$PAM_RHOST \$1"
}

PAM_OTP=\`cat -\`

# Block all non-ssh connections
if [ "\$PAM_TTY" != "ssh" ]; then
  log "Invalid connection (\$PAM_TTY)"
  exit \$PAM_IGNORE
fi

if [ "\$PAM_USER" == "ec2-user" ]; then
  log "Success, ec2-user"
  exit \$PAM_SUCCESS
fi

# assume role try
# Generate tmp access key
#KEYS=\$(aws iam create-access-key --user-name \$PAM_USER)
#AWS_ACCESS_KEY_ID=\$( sed -n 's/.*"AccessKeyId": "\(.*\)",/\1/p' \$KEYS )
#AWS_SECRET_ACCESS_KEY=\$( sed -n 's/.*"AccessKeyId": "\(.*\)",/\1/p' \$KEYS )

# Virtual Device
# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa_checking-status.html
#MFA_RESULT=\$(AWS_ACCESS_KEY_ID=\$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=\$AWS_SECRET_ACCESS_KEY aws sts assume-role \
#    --role-arn arn:aws:iam::\$ACCOUNT_ID:role/\$PAM_ROLE \
#    --role-session-name pam-mfa-\$PAM_USER \
#    --serial-number arn:aws:iam::\$ACCOUNT_ID:mfa/\$PAM_USER \
#    --token-code \$PAM_OTP 2>&1 | xargs)

# Remove tmp access key
#aws iam delete-access-key --user-name \$PAM_USER --access-key-id \$ACCESS_KEY_ID

#if [ ! -f /root/.aws/credentials ] || [ grep -Fxq "[\$PAM_USER]" /root/.aws/credentials ]; then
#  KEYS=\$(aws iam create-access-key --user-name \$PAM_USER)
#  echo \$KEYS
#  AWS_ACCESS_KEY_ID=\$( sed -n 's/.*"AccessKeyId": "\(.*\)",/\1/p' "\$KEYS" )
#  AWS_SECRET_ACCESS_KEY=\$( sed -n 's/.*"AccessKeyId": "\(.*\)",/\1/p' "\$KEYS" )
#  mkdir -p /home/\$PAM_USER/.aws
#  cat << EOF >> /root/.aws/credentials
#  [\$PAM_USER]
#  aws_access_key_id=\$AWS_ACCESS_KEY_ID
#  aws_secret_access_key_id=\$AWS_SECRET_ACCESS_KEY
#  EOF
#fi

#MFA_RESULT=\$(aws --profile \$PAM_USER sts get-session-token \
#    --serial-number arn:aws:iam::${ACCOUNT_ID}:mfa/\$PAM_USER \
#    --token-code \$PAM_OTP 2>&1 | xargs)

#echo "\$MFA_RESULT"

if [[ "\$PAM_OTP" == "" ]] || [[ "\$MFA_RESULT" = *"Parameter validation failed"* ]] || [[ "\$MFA_RESULT" = *"An error occurred"* ]]; then
  log "\$MFA_RESULT"
  exit \$PAM_SERVICE_ERR
fi

log "Success"
exit \$PAM_SUCCESS
EOF
chmod +x /usr/bin/pam_verify

cat << EOF > /etc/pam.d/sshd
#%PAM-1.0
auth       sufficient   pam_exec.so expose_authtok quiet debug log=/var/log/pam.log /usr/bin/pam_verify
auth       [success=1 default=ignore] pam_unix.so nullok_secure
auth       requisite    pam_deny.so

auth       required     pam_sepermit.so
auth       substack     password-auth
auth       include      postlogin
# Used with polkit to reauthorize users in remote sessions
-auth      optional     pam_reauthorize.so prepare
account    required     pam_nologin.so
account    include      password-auth
password   include      password-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    required     pam_loginuid.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open env_params
session    required     pam_namespace.so
session    optional     pam_keyinit.so force revoke
session    include      password-auth
session    include      postlogin
# Used with polkit to reauthorize users in remote sessions
-session   optional     pam_reauthorize.so prepare
EOF

sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config
cat << EOF >> /etc/ssh/sshd_config
# AWS IAM PAM
#AuthenticationMethods publickey,keyboard-interactive
EOF

# TODO figure out ho to change display text `Password` to `MFA Code` (https://community.centrify.com/t5/Centrify-Infrastructure-Services/How-do-I-change-the-password-prompt-text-that-is-displayed-when/td-p/30263)

/etc/init.d/sshd restart
