#!/usr/bin/env bash

echo "***** Update *****"
yum update -y

echo "***** Install pip *****"
curl -O https://bootstrap.pypa.io/get-pip.py
python get-pip.py

echo "***** Update awscli *****"
pip install --upgrade awscli

echo "***** Setup CloudWatch Logging *****"
yum install awslogs -y
cat << EOF > /etc/init.d/configure-awslogs
#!/bin/sh
# chkconfig: 2345 94 26
# description:      This script is responsible for configuring AWSLogs agent. Needs to run before awslogs.

start() {
  INSTANCE_ID=\$(curl -s -m 60 http://169.254.169.254/latest/meta-data/instance-id)
  sed -i "s/{instance_id}/\$INSTANCE_ID/" /etc/awslogs/awslogs.conf
}

case "\$1" in 
    start)
       start
       ;;
    *)
       echo "Usage: \$0 start"
esac

exit 0 
EOF
chmod +x /etc/init.d/configure-awslogs
chkconfig --add configure-awslogs 
chkconfig configure-awslogs on
chkconfig awslogs on

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
curl -O https://inspector-agent.amazonaws.com/linux/latest/install
bash install

echo "***** Setup SSM Agent *****"
# https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-manual-agent-install.html
# already built into Amazon Linux 2 AMI

echo "***** Setup the EFS mount helper *****"
yum install -y amazon-efs-utils

echo "***** Setup ECS CLI *****"
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html
sudo curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest
#echo "$(curl -s https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest.md5) /usr/local/bin/ecs-cli" | md5sum -c -
