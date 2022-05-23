#!/bin/bash

while getopts d:s: flag
do
    case "${flag}" in
        d) domains=${OPTARG};;
        s) staging="1";;
        e) email=${OPTARG}
    esac
done
if [ -z "$domains" ]; then domains="www.example.protolemon.com example.protolemon.com"; fi
if [ -z "$staging" ]; then staging="0"; fi
if [ -z "$email" ]; then email="zogz.max@gmail.com"; fi

docker build nginx -f nginx/Dockerfile-init -t nginx-temp

docker run -d --name nginx-temp \
            -v "$pwd/data/certbot/letsencrypt:/etc/letsencrypt" \
            -v "$pwd/data/certbot/www:/var/www" \
            nginx-temp

docker run --rm --name temp_certbot \
    -v "$pwd/data/certbot/letsencrypt:/etc/letsencrypt" \
    -v "$pwd/data/certbot/www:/var/www" \
    certbot/certbot \
    certonly --webroot --agree-tos --renew-by-default \
    --preferred-challenges http-01 --server https://acme-v02.api.letsencrypt.org/directory \
    --text --email zogz.max@gmail.com \
    --test-cert \
    -w /var/www -d example.protolemon.com