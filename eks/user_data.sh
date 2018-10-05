#!/usr/bin/env bash

echo "***** Connect to Cluster *****"
/etc/eks/bootstrap.sh --apiserver-endpoint '${APISERVER_ENDPOINT}' --b64-cluster-ca '${CLUSTER_CA}' '${CLUSTER_NAME}'

cat <<EOF > config-map-aws-auth.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${ROLE_ARN}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes

EOF

kubectl apply -f config-map-aws-auth.yaml
