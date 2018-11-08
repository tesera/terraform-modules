#!/usr/bin/env bash

echo "***** Update *****"
yum update -y

echo "***** Install pip *****"
curl -O https://bootstrap.pypa.io/get-pip.py
python get-pip.py

echo "***** Update awscli *****"
/usr/local/bin/pip install --upgrade awscli

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

echo "***** Setup Auto-Tuning *****"
# https://aws.amazon.com/premiumsupport/knowledge-center/vpc-nat-instance/
# For larger instances only
# error: "net.ipv4.netfilter.ip_conntrack_max" is an unknown key
cat << EOF > /etc/sysctl.d/custom_nat_tuning.conf
# for large instance types, allow keeping track of more
# connections (requires enough RAM)
net.ipv4.netfilter.ip_conntrack_max=262144
EOF

cat << EOF > /etc/init.d/configure-nat
#!/bin/sh
# chkconfig: 2345 96 26
# description: This script is responsible for configuring NAT settings

start() {
  REGION=\$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print \$4}')
  INSTANCE_ID=\$(curl -s -m 60 http://169.254.169.254/latest/meta-data/instance-id)

  aws ec2 --region \$REGION modify-instance-attribute --no-source-dest-check --instance-id \$INSTANCE_ID

  sysctl -p /etc/sysctl.d/custom_nat_tuning.conf
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
chmod +x /etc/init.d/configure-nat
chkconfig --add configure-nat 
chkconfig configure-nat on

echo "***** Update *****"
yum update -y

# TODO apply other CIS changes
# or swap out base image for https://aws.amazon.com/marketplace/pp/B078TPXMH2?qid=1530714745994&sr=0-1&ref_=srh_res_product_title

# TODO setup av
# https://www.centosblog.com/how-to-install-clamav-and-configure-daily-scanning-on-centos/

