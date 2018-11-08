#!/usr/bin/env bash

echo "***** Instance ENV *****"
INSTANCE_ID=$(curl -s -m 60 http://169.254.169.254/latest/meta-data/instance-id)

echo "***** Update *****"
yum update -y
pip install --upgrade awscli

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
