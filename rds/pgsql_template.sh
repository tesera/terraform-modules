#/bin/bash
#The following two lines are needed, to avoid an issue where we can not change the permission of files in the docker mounted volume 
cp /data/${SSH_IDENTITY_FILE} /root/${SSH_IDENTITY_FILE}
chmod 600 /root/${SSH_IDENTITY_FILE} 
if [ "$USE_BASTION" = "true" ]
then
	ssh -4 -o StrictHostKeyChecking=no -i /root/${SSH_IDENTITY_FILE} ${SSH_USERNAME}@${BASTION_IP} -L 5432:${DB_HOST}:${DB_PORT} -fNT
	cat /data/${INIT_SCRIPTS_FOLDER}/*.sql | psql -h 127.0.0.1 -d ${DATABASE_NAME} -1 -o /data/init_script_messages.txt
else
	cat /data/${INIT_SCRIPTS_FOLDER}/*.sql | psql -h ${DB_HOST} -p ${DB_PORT} -d ${DATABASE_NAME} -1 -o /data/init_script_messages.txt
fi


