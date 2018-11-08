#/bin/bash
#The following two lines are needed, to avoid an issue where we can not change the permission of files in the docker mounted volume 
cp /data/${SSH_IDENTITY_FILE} /root/${SSH_IDENTITY_FILE}
chmod 600 /root/${SSH_IDENTITY_FILE} 
cd /data
npm install elasticsearch

if [ "$USE_BASTION" = "true" ]
then
	ssh -4 -o StrictHostKeyChecking=no -i /root/${SSH_IDENTITY_FILE} ${SSH_USERNAME}@${BASTION_IP} -L 9200:${ELASTICSEARCH_ENDPOINT}:443 -fNT
  node indices.js ${INDICES_CONFIG_FILE} localhost 9200
else
  node indices.js ${INDICES_CONFIG_FILE} ${ELASTICSEARCH_ENDPOINT} 443
fi


