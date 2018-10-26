#!/usr/bin/env bash

echo "***** Update *****"
sudo yum update -y

echo "***** Install pip *****"
curl -O https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py

echo "***** Update awscli *****"
sudo pip install --upgrade awscli

echo "***** Install epel and figlet for setting up banner *****"
sudo amazon-linux-extras install epel -y
sudo yum install figlet -y

echo "***** Setup fail2ban *****"
sudo yum install fail2ban -y
sudo service fail2ban start

echo "***** Setup SSH via IAM *****"
sudo rpm -i https://s3-eu-west-1.amazonaws.com/widdix-aws-ec2-ssh-releases-eu-west-1/aws-ec2-ssh-1.9.1-1.el7.centos.noarch.rpm

echo "***** Setup CloudWatch Logging *****"
sudo yum install -y awslogs

echo "***** Setup CloudWatch Agent *****"
sudo bash -c 'cat << EOF > /etc/cloudwatch-agent.conf
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
EOF'

sudo rpm -i https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/etc/cloudwatch-agent.conf -s

echo "***** Setup Inspector Agent *****"
wget https://inspector-agent.amazonaws.com/linux/latest/install
sudo bash install

echo "***** Update *****"
sudo yum update -y