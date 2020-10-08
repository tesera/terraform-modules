#!/usr/bin/env bash

echo "***** Setup SSH via IAM *****"
cat << EOF > /etc/aws-ec2-ssh.conf
IAM_AUTHORIZED_GROUPS="${IAM_AUTHORIZED_GROUPS}"
SUDOERS_GROUPS="${SUDOERS_GROUPS}"
ASSUMEROLE="${ASSUMEROLE}"
LOCAL_GROUPS="${LOCAL_GROUPS}"
EOF

/usr/bin/import_users.sh
