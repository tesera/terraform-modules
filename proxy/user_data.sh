
echo "***** Attach IP [Public Subnet Only] *****"
aws --region $REGION ec2 associate-address --instance-id $INSTANCE_ID --allocation-id ${EIP_ID}

echo "***** Nginx *****"
rm /etc/nginx/conf.d/virtual.conf
mkdir -p /etc/nginx/conf.d/streams

cat << EOF > /etc/nginx/nginx.conf
load_module /usr/lib64/nginx/modules/ngx_stream_module.so;

user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

include    main.d/*.conf;

events {
    worker_connections  1024;
}

http {
    include /etc/nginx/conf.d/*.conf;
}

stream {
    include /etc/nginx/conf.d/streams/*.conf;
}
EOF

# Future http proxy
#cat << EOF > /etc/nginx/conf.d/${PROXY_NAME}.conf
#upstream ${PROXY_NAME} {
#    zone backend 64k;
#    server ${PROXY_ENDPOINT};
#}
#
#server {
#    listen ${PROXY_PORT};
#    proxy_pass ${PROXY_NAME};
#    proxy_connect_timeout 1s;
#}
#EOF

# https://www.nginx.com/blog/advanced-mysql-load-balancing-with-nginx-plus/
cat << EOF > /etc/nginx/conf.d/streams/${PROXY_NAME}.conf
upstream ${PROXY_NAME} {
    zone backend 64k;
    server ${PROXY_ENDPOINT};
}

server {
    listen ${PROXY_PORT};
    proxy_pass ${PROXY_NAME};
    proxy_connect_timeout 1s;
}
EOF




ls /etc/nginx/conf.d

service nginx start
