#!/usr/bin/env bash

echo "***** Update *****"
yum update -y
yum install -y nginx
pip install --upgrade awscli
#yum install epel-release -y

echo "***** Setup Banner *****"
yum install figlet -y
BANNER=$(figlet "Proxy" | sed "s/\`/\'/")
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
LOCAL_GROUPS=""
EOF
/usr/bin/import_users.sh

echo "***** Nginx *****"
#rm /etc/nginx/conf.d/default.conf

cat << EOF > /etc/nginx/nginx.conf
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

include    main.d/*.conf;

events {
    worker_connections  1024;
}

stream {
    include /etc/nginx/conf.d/*.conf;
}
EOF

# https://www.nginx.com/blog/advanced-mysql-load-balancing-with-nginx-plus/
cat << EOF > /etc/nginx/conf.d/${PROXY_NAME}.conf
upstream ${PROXY_NAME} {
    zone backend 64k;
    server ${PROXY_ENDPOINT}:${PROXY_PORT}
}

server {
    listen ${PROXY_PORT};
    status_zone tcp_server;
    proxy_pass ${PROXY_NAME};
    proxy_connect_timeout 1s;
    health_check port=${PROXY_HEALTH_PORT};
}
EOF

ls /etc/nginx/conf.d

nginx -g daemon off;

echo "***** Clean Up *****"

