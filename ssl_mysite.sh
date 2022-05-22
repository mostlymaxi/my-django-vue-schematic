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

echo "### Using domain: $domains";

export CERT_DIR_PATH="./data/certbot/letsencrypt";
export WEBROOT_PATH="./data/certbot/www";
export LE_RENEW_HOOK="docker-compose up --build"; # <--- change to your nginx server docker container name
export DOMAINS=domains;
export EMAIL=email;
export EXP_LIMIT="30";
export CHECK_FREQ="30";
export CHICKENEGG="1";
export STAGING=staging;

bash ./data/certbot/ssl_update.sh