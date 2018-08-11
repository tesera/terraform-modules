#/bin/bash
cp /data/${SSH_KEY_FILE_NAME} /root/${SSH_KEY_FILE_NAME}
chmod 600 /root/${SSH_KEY_FILE_NAME}
if [ "$USE_BASTION" = "true" ]
then
	ssh -4 -o StrictHostKeyChecking=no -i /root/${SSH_KEY_FILE_NAME} ${BASTION_USERNAME}@${BASTION_IP} -L 5432:${DB_HOST}:${DB_PORT} -fNT
	psql -h 127.0.0.1 -d ${DATABASE_NAME} -f /data/${DB_INITFILENAME} -1 -o /data/init_script_messages.txt
else
	psql -h ${DB_HOST} -p ${DB_PORT} -d ${DATABASE_NAME} -f /data/${DB_INITFILENAME} -1 -o /data/init_script_messages.txt
fi


