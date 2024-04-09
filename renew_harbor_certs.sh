#!/bin/bash

echo "Stoping Nginx"
/usr/bin/docker stop nginx

echo "====Testing certbot connection===="
certbot renew --dry-run

echo "====Issue Certs===="
certbot renew

echo "====Provide the Certificates to Harbor and Docker===="
cp -f /etc/letsencrypt/live/registry.example.com/fullchain.pem /data/secret/cert/server.crt
cp -f /etc/letsencrypt/live/registry.example.com/privkey.pem /data/secret/cert/server.key

echo "Starting Nginx"
/usr/bin/docker start nginx


