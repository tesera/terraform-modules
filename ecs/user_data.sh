#!/usr/bin/env bash

echo "***** Connect to Cluster *****"
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-config.html
cat << EOF >> /etc/ecs/ecs.config
ECS_CLUSTER=${ECS_CLUSTER}
NO_PROXY=169.254.169.254,169.254.170.2,/var/run/docker.sock
EOF
