#!/usr/bin/env bash

echo "***** Update *****"
yum update -y

echo "***** Install unzip *****"
yum install unzip  -y

echo "***** Setup SSH via IAM *****"
# https://github.com/widdix/aws-ec2-ssh
sed -i 's@AuthorizedKeysCommand /usr/bin/timeout 5s /opt/aws/bin/curl_authorized_keys %u %f@#AuthorizedKeysCommand /usr/bin/timeout 5s /opt/aws/bin/curl_authorized_keys %u %f@g' /etc/ssh/sshd_config
sed -i 's@AuthorizedKeysCommandUser ec2-instance-connect@#AuthorizedKeysCommandUser ec2-instance-connect@g' /etc/ssh/sshd_config
rpm -i https://s3-eu-west-1.amazonaws.com/widdix-aws-ec2-ssh-releases-eu-west-1/aws-ec2-ssh-1.9.2-1.el7.centos.noarch.rpm
#rpm -i https://s3-eu-west-1.amazonaws.com/widdix-aws-ec2-ssh-releases-eu-west-1/aws-ec2-ssh-1.10.0-1.el7.centos.noarch.rpm

echo "***** Setup CloudWatch Logging *****"
yum install awslogs -y
cat << EOF > /usr/local/bin/configure-awslogs.sh
#!/usr/bin/env bash
INSTANCE_ID=$(curl -s -m 60 http://169.254.169.254/latest/meta-data/instance-id)
sed -i "s/{instance_id}/\$INSTANCE_ID/" /etc/awslogs/awslogs.conf
EOF
chmod +x /usr/local/bin/configure-awslogs.sh
sed -i '/ExecStart=/i ExecStartPre=/usr/local/bin/configure-awslogs.sh' /usr/lib/systemd/system/awslogsd.service
systemctl start awslogsd
systemctl enable awslogsd.service

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

#rpm -i https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
yum install amazon-cloudwatch-agent -y
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/etc/cloudwatch-agent.conf -s


echo "***** Setup X-Ray Service"
curl https://s3.dualstack.us-east-2.amazonaws.com/aws-xray-assets.us-east-2/xray-daemon/aws-xray-daemon-3.x.rpm -o /home/ec2-user/xray.rpm
yum install -y /home/ec2-user/xray.rpm
systemctl enable xray

echo "***** Setup Inspector Agent *****"
wget https://inspector-agent.amazonaws.com/linux/latest/install
bash install

echo "***** Setup the EFS mount helper *****"
yum install -y amazon-efs-utils

echo "***** Install Git *****"
yum install -y git

echo "***** Install Docker *****"
amazon-linux-extras install docker -y
systemctl start docker
usermod -a -G docker ec2-user
systemctl enable docker

echo "***** Update *****"
yum update -y

echo "***** Services *****"
systemctl list-unit-files --state=enabled



