#!/usr/bin/env bash

echo "***** Connect to Cluster *****"
echo ECS_CLUSTER=${ECS_CLUSTER} >> /etc/ecs/ecs.config
