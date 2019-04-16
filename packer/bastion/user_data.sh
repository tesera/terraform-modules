#!/usr/bin/env bash

echo "***** Update *****"
yum update -y

echo "***** Install pip *****"
curl -O https://bootstrap.pypa.io/get-pip.py
python get-pip.py

echo "***** Update awscli *****"
pip install --upgrade awscli

echo "***** Install epel and figlet for setting up banner *****"
amazon-linux-extras install epel -y
yum install figlet -y

BANNER=$(figlet "Bastion" | sed "s/\`/\'/g")
cat << EOF > /etc/update-motd.d/30-banner
#!/usr/bin/env bash
IP=\$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
INSTANCE_TYPE=\$(curl -s http://169.254.169.254/latest/meta-data/instance-type)
AVAILABILITY_ZONE=\$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
cat << MOTD
$BANNER
Private IP:        \$IP
Availability Zone: \$AVAILABILITY_ZONE
Instance Type:     \$INSTANCE_TYPE

MOTD
EOF
yum remove figlet -y

echo "***** Setup fail2ban *****"
yum install fail2ban -y
systemctl enable fail2ban

echo "***** Setup SSH via IAM *****"
# 2018-10-31 Amazon Linux 2 was pushed with a breaking change
# https://aws.amazon.com/de/amazon-linux-2/release-notes/
# https://github.com/widdix/aws-ec2-ssh/issues/142
sed -i 's@AuthorizedKeysCommand /usr/bin/timeout 5s /opt/aws/bin/curl_authorized_keys %u %f@#AuthorizedKeysCommand /usr/bin/timeout 5s /opt/aws/bin/curl_authorized_keys %u %f@g' /etc/ssh/sshd_config
sed -i 's@AuthorizedKeysCommandUser ec2-instance-connect@#AuthorizedKeysCommandUser ec2-instance-connect@g' /etc/ssh/sshd_config
rpm -i https://s3-eu-west-1.amazonaws.com/widdix-aws-ec2-ssh-releases-eu-west-1/aws-ec2-ssh-1.9.1-1.el7.centos.noarch.rpm

echo "***** Setup CloudWatch Logging *****"
yum install awslogs -y
cat << EOF > /usr/local/bin/configure-awslogs.sh
#!/usr/bin/env bash
INSTANCE_ID=$(curl -s -m 60 http://169.254.169.254/latest/meta-data/instance-id)
sed -i "s/{instance_id}/\$INSTANCE_ID/" /etc/awslogs/awslogs.conf
EOF
chmod +x /usr/local/bin/configure-awslogs.sh
sed -i '/ExecStart=/i ExecStartPre=/usr/local/bin/configure-awslogs.sh' /usr/lib/systemd/system/awslogsd.service
systemctl enable awslogsd

echo "***** Setup CloudWatch Agent *****"
cat << EOF > /etc/cloudwatch-agent.conf
{
  "metrics": {
    "append_dimensions": {
      "AutoScalingGroupName": "\${aws:AutoScalingGroupName}",
      "ImageId": "\${aws:ImageId}",
      "InstanceId": "\${aws:InstanceId}",
      "InstanceType": "\${aws:InstanceType}"
    },
    "metrics_collected": {
      "mem": {
        "measurement": [
          "mem_used",
          "mem_cached",
          "mem_total"
        ],
        "metrics_collection_interval": 10
      },
      "swap": {
        "measurement": [
          "swap_used",
          "swap_free",
          "swap_used_percent"
        ],
        "metrics_collection_interval": 10
      },
      "disk": {
        "resources": [
          "/",
          "/tmp"
        ],
        "measurement": [
          "free",
          "total",
          "used"
        ],
        "ignore_file_system_types": [
          "sysfs",
          "devtmpfs",
          "tmpfs"
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

rpm -i https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/etc/cloudwatch-agent.conf -s

echo "***** Setup Inspector Agent *****"
wget https://inspector-agent.amazonaws.com/linux/latest/install
bash install

echo "***** Setup SSM Agent *****"
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

echo "***** Update *****"
yum update -y
