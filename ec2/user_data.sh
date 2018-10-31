#!/usr/bin/env bash

echo "***** Instance ENV *****"
INSTANCE_ID=$(curl -s -m 60 http://169.254.169.254/latest/meta-data/instance-id)

echo "***** Update *****"
yum update -y
pip install --upgrade awscli

# TODO apply other CIS changes
# or swap out base image for https://aws.amazon.com/marketplace/pp/B078TPXMH2?qid=1530714745994&sr=0-1&ref_=srh_res_product_title

# TODO setup av
# https://www.centosblog.com/how-to-install-clamav-and-configure-daily-scanning-on-centos/

echo "***** Configure CloudWatch Logging *****"
sed -i "s/{instance_id}/$INSTANCE_ID/" /etc/awslogs/awslogs.conf
#This check is needed for when this module is used with Amazon Linux (NOT Amazon Linux 2).
#In Amazon Linux this service is called awslogs, and the client module is responsible for starting it
if [ -e /usr/lib/systemd/system/awslogsd.service ]
then
  service awslogsd start
fi

echo "***** Setup EFS *****"
OIFS=$IFS
IFS=","
EFS_COUNTER=1
EFS_IDS=${EFS_IDS}
for EFS_ID in $EFS_IDS
do
  MOUNT_POINT=/mnt/efs$((EFS_COUNTER++))
  mkdir -p $MOUNT_POINT
  mount -t efs $EFS_ID:/ $MOUNT_POINT
done
IFS=$OIFS

echo "***** Execute User Data *****"
${USER_DATA}

echo "***** Clean Up *****"
