#!/bin/bash

if [[ -z $DOMAINS ]]; then
  echo "No domains set, please fill -e 'DOMAINS=example.com www.example.com'"
  exit 1
fi

if [[ -z $EMAIL ]]; then
  echo "No email set, please fill -e 'EMAIL=your@email.tld'"
  exit 1
fi

if [[ -z $CERT_DIR_PATH ]]; then
  echo "No cert dir path set, please fill -e 'CERT_DIR_PATH=/etc/letsencrypt'"
  exit 1
fi

if [[ -z $WEBROOT_PATH ]]; then
  echo "No webroot path set, please fill -e 'WEBROOT_PATH=/tmp/letsencrypt'"
  exit 1
fi

if [[ $STAGING -eq 1 ]]; then
  echo "Using the staging environment"
  ADDITIONAL="--staging"
fi

DARRAYS=(${DOMAINS})
EMAIL_ADDRESS=${EMAIL}
LE_DOMAINS=("${DARRAYS[*]/#/-d }")

exp_limit="${EXP_LIMIT:-30}"
check_freq="${CHECK_FREQ:-30}"

le_hook()
{
    command=$(echo $LE_RENEW_HOOK)
    echo "[INFO] Run: $command"
    eval $command

}

le_fixpermissions() {
    echo "[INFO] Fixing permissions"
        chown -R ${CHOWN:-root:root} ${CERT_DIR_PATH}
        find ${CERT_DIR_PATH} -type d -exec chmod 755 {} \;
        find ${CERT_DIR_PATH} -type f -exec chmod ${CHMOD:-644} {} \;
}

le_renew() {
    docker run --rm --name temp_certbot \
        -v "${CERT_DIR_PATH}:/etc/letsencrypt" \
        -v "${WEBROOT_PATH}:/tmp/letsencrypt" \
        -v "/$(pwd)/data/servers-data/certbot/log:/var/log" \
        certbot/certbot:v1.8.0 certonly --webroot --agree-tos --renew-by-default  \
            --preferred-challenges http-01 \
            --server https://acme-v02.api.letsencrypt.org/directory --text ${ADDITIONAL} \
            --email ${EMAIL_ADDRESS} -w /tmp/letsencrypt ${LE_DOMAINS}

    le_fixpermissions
    le_hook
}

le_check() {
    cert_file="$CERT_DIR_PATH/live/$DARRAYS/fullchain.pem";

    echo "START check";
    echo "file: $cert_file";

    if [[ -e $cert_file ]]; then

        exp=$(date -d "`openssl x509 -in $cert_file -text -noout|grep "Not After"|cut -c 25-`" +%s)
        datenow=$(date -d "now" +%s)
        days_exp=$[ ( $exp - $datenow ) / 86400 ]

        echo "Checking expiration date for $DARRAYS..."

        if [ "$days_exp" -gt "$exp_limit" ] ; then
            echo "The certificate is up to date, no need for renewal ($days_exp days left)."
        else
            echo "The certificate for $DARRAYS is about to expire soon. Starting webroot renewal script..."
            le_renew
            echo "Renewal process finished for domain $DARRAYS"
        fi

        echo "Checking domains for $DARRAYS..."

        domains=($(openssl x509  -in $cert_file -text -noout | grep -oP '(?<=DNS:)[^,]*'))
        new_domains=($(
            for domain in ${DARRAYS[@]}; do
                [[ " ${domains[@]} " =~ " ${domain} " ]] || echo $domain
            done
        ))

        if [ -z "$new_domains" ] ; then
            echo "The certificate have no changes, no need for renewal"
        else
            echo "The list of domains for $DARRAYS certificate has been changed. Starting webroot renewal script..."
            le_renew
            echo "Renewal process finished for domain $DARRAYS"
        fi


    else
      echo "[INFO] certificate file not found for domain $DARRAYS. Starting webroot initial certificate request script..."
      if [[ $CHICKENEGG -eq 1 ]]; then
        echo "Making a temporary self signed certificate to prevent chicken and egg problems"

        mkdir -p $CERT_DIR_PATH/live/$DARRAYS
        openssl req -x509 -newkey rsa:4096 -sha256 -nodes -keyout "$CERT_DIR_PATH/live/$DARRAYS/privkey.pem" -out "${cert_file}" -subj "/CN=example.com" -days 1
      fi

      le_renew
      echo "Certificate request process finished for domain $DARRAYS"
    fi

}

echo "--- start. $(date)";

le_check $1