#!/usr/bin/env bash

echo "***** Connect to Cluster *****"
cat << EOF >> /etc/ecs/ecs.config
ECS_CLUSTER=${ECS_CLUSTER}
NO_PROXY=169.254.169.254,169.254.170.2,/var/run/docker.sock >> /etc/ecs/ecs.config
EOF

