#!/bin/bash

print_help() {
  printf "Usage: ./init [-d protolemon.com] [-e email@email.com] [-s] [-z] \n"
  printf "\t -d: main domain name \n\t -e: email for certbot \n\t -s: boolean flag for certbot staging \n"
  echo
  exit 1
}

domain="protolemon.com"
staging=""
email="zogz.max@gmail.com"

while getopts d:e:sh flag
do
    case "${flag}" in
        d) domain=${OPTARG};;
        e) email=${OPTARG};;
        s) staging="--staging";;
        h) print_help;;
        *) print_help;;
    esac
done

read -p "### Enter a new subdomain name: " subdomain

sed "s/example\./${subdomain}./g" ./nginx/templates/default-template.conf > ./nginx/default.conf
sed "s/example\./${subdomain}./g" ./nginx/templates/init-template.conf > ./nginx/init.conf

domains="${subdomain}.${domain} www.${subdomain}.${domain}"
darrays=(${domains})
d_domains=("${darrays[*]/#/-d }") 

echo "### Updating packages..."
apt update

echo "### Initializing temporary nginx container..."
docker build nginx -f nginx/Dockerfile-init -t nginx-temp

docker run --rm -d --name nginx-temp \
            -v "$(pwd)"/data/certbot/letsencrypt:/etc/letsencrypt\ \
            -v certbot_challenges:/var/www/html \
            -p 80:80 \
            nginx-temp


echo "### Running certbot..."
docker run --rm --name certbot-temp \
    -v "$(pwd)"/data/certbot/letsencrypt:/etc/letsencrypt \
    -v certbot_challenges:/var/www/html \
    certbot/certbot \
    certonly --webroot --text --agree-tos --renew-by-default \
    --keep-until-expiring \
    --preferred-challenges http-01 --server https://acme-v02.api.letsencrypt.org/directory \
    --text --email ${email} ${staging} \
    -w /var/www/html ${d_domains}

echo "### Shutting down temporary nginx container... "
docker stop nginx-temp

echo "### Writing crontab to auto update certbot... "
apt install cron
systemctl enable cron
crontab -l > temp_crontab

echo "0 0 * * * \
docker run --rm --name certbot-temp \
-v "$(pwd)"/data/certbot/letsencrypt:/etc/letsencrypt \
-v certbot_challenges:/var/www/html \
certbot/certbot \
certonly --webroot --text --agree-tos --renew-by-default \
--keep-until-expiring \
--preferred-challenges http-01 --server https://acme-v02.api.letsencrypt.org/directory \
--text --email ${email} ${staging} \
-w /var/www/html ${d_domains}" >> temp_crontab

echo "1 0 * * * docker-compose exec nginx nginx -s reload" >> temp_crontab

crontab temp_crontab
rm temp_crontab
systemctl status cron

read -p "### Initialize docker containers? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi

docker-compose up --build

exit 0