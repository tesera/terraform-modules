#!/usr/bin/env bash

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
