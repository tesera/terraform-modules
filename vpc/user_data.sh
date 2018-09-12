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

echo "***** Setup SSH via IAM *****"
rpm -i https://s3-eu-west-1.amazonaws.com/widdix-aws-ec2-ssh-releases-eu-west-1/aws-ec2-ssh-1.9.1-1.el7.centos.noarch.rpm
cat << EOF > /etc/aws-ec2-ssh.conf
IAM_AUTHORIZED_GROUPS="${IAM_AUTHORIZED_GROUPS}"
SUDOERS_GROUPS="${SUDOERS_GROUPS}"
LOCAL_GROUPS="${LOCAL_GROUPS}"
EOF

/usr/bin/import_users.sh

##############################

echo "***** Setup Networking *****"
cat << EOF > /usr/local/sbin/configure-pat.sh
#!/bin/bash
# Configure the instance to run as a Port Address Translator (PAT) to provide
# Internet connectivity to private instances.

function log { logger -t "vpc" -- \$1; }

function die {
    [ -n "\$1" ] && log "\$1"
    log "Configuration of PAT failed!"
    exit 1
}

# Sanitize PATH
PATH="/usr/sbin:/sbin:/usr/bin:/bin"

log "Determining the MAC address on eth0..."
ETH0_MAC=\$(cat /sys/class/net/eth0/address) ||
    die "Unable to determine MAC address on eth0."
log "Found MAC \$ETH0_MAC for eth0."

VPC_CIDR_URI="http://169.254.169.254/latest/meta-data/network/interfaces/macs/\$ETH0_MAC/vpc-ipv4-cidr-block"
log "Metadata location for vpc ipv4 range: \$VPC_CIDR_URI"

VPC_CIDR_RANGE=\$(curl --retry 3 --silent --fail \$VPC_CIDR_URI)
if [ \$? -ne 0 ]; then
   log "Unable to retrieve VPC CIDR range from meta-data, using 0.0.0.0/0 instead. PAT may be insecure!"
   VPC_CIDR_RANGE="0.0.0.0/0"
else
   log "Retrieved VPC CIDR range \$VPC_CIDR_RANGE from meta-data."
fi

log "Enabling PAT..."
sysctl -q -w net.ipv4.ip_forward=1 net.ipv4.conf.eth0.send_redirects=0 && (
   iptables -t nat -C POSTROUTING -o eth0 -s \$VPC_CIDR_RANGE -j MASQUERADE 2> /dev/null ||
   iptables -t nat -A POSTROUTING -o eth0 -s \$VPC_CIDR_RANGE -j MASQUERADE ) ||
       die

sysctl net.ipv4.ip_forward net.ipv4.conf.eth0.send_redirects | log
iptables -n -t nat -L POSTROUTING | log

log "Configuration of PAT complete."
exit 0
EOF
chmod +x /usr/local/sbin/configure-pat.sh
/usr/local/sbin/configure-pat.sh

# Verify
#iptables -L -n -v -x -t nat
#cat /proc/sys/net/ipv4/ip_forward

# Route Tables
aws ec2 --region $REGION create-route --destination-cidr-block 0.0.0.0/0 --instance-id $INSTANCE_ID --route-table-id ${ROUTE_TABLE_ID}

echo "***** Setup Auto-Tuning *****"
# For larger instances only
# error: "net.ipv4.netfilter.ip_conntrack_max" is an unknown key
cat << EOF > /etc/sysctl.d/custom_nat_tuning.conf
# for large instance types, allow keeping track of more
# connections (requires enough RAM)
net.ipv4.netfilter.ip_conntrack_max=262144
EOF
sysctl -p /etc/sysctl.d/custom_nat_tuning.conf


#echo 655361 > /proc/sys/net/netfilter/nf_conntrack_max
#
#mkdir -p /etc/sysctl.d/
#cat <<EOF > /etc/sysctl.d/nat.conf
#net.ipv4.ip_forward = 1
#net.ipv4.conf.eth0.send_redirects = 0
#EOF

echo "***** Setup Firewall *****"
#iptables -t nat -A POSTROUTING -o eth0 -s 0.0.0.0/0 -j MASQUERADE
#iptables-save > /etc/sysconfig/iptables

#iptables -N LOGGINGF
#iptables -N LOGGINGI
#iptables -A LOGGINGF -m limit --limit 2/min -j LOG --log-prefix "IPTables-FORWARD-Dropped: " --log-level 4
#iptables -A LOGGINGI -m limit --limit 2/min -j LOG --log-prefix "IPTables-INPUT-Dropped: " --log-level 4
#iptables -A LOGGINGF -j DROP
#iptables -A LOGGINGI -j DROP
#iptables -A FORWARD -s ${VPC_CIDR} -j ACCEPT
#iptables -A FORWARD -j LOGGINGF
#iptables -P FORWARD DROP
#iptables -I FORWARD -m state --state "ESTABLISHEDRELATED" -j ACCEPT
#iptables -t nat -I POSTROUTING -s ${VPC_CIDR} -d 0.0.0.0/0 -j MASQUERADE
#iptables -A INPUT -s ${VPC_CIDR} -j ACCEPT
#iptables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT
#iptables -I INPUT -m state --state "ESTABLISHEDRELATED" -j ACCEPT
#iptables -I INPUT -i lo -j ACCEPT
#iptables -A INPUT -j LOGGINGI
#iptables -P INPUT DROP
