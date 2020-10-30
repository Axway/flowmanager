#!/bin/bash

if [ ! -f ./docker-compose.yml ]; then
    cd ../docker-compose
     if [ ! -f ./docker-compose.yml ]; then
          echo "You should launch this script from docker-compose directory!"
          exit 1
     fi
fi

set -euo pipefail
err_report() {
    echo "Error on line $1"
}

trap 'err_report $LINENO' ERR

site=example.com
email=anonymous@axway.com
password=Secret01

function gen_ca() {
    local name=$1
    local root=./custom-ca/$name
    local site="$name.com"
    echo "gen_ca name $site  ...."

    rm -rf $root
    mkdir -p $root
    > $root/index.txt
    echo -n "01" > $root/serial
    cat >$root/ca.cnf <<EOF

[ ca ]
default_ca = miniCA

[policy_match]
commonName = supplied
countryName = optional
stateOrProvinceName = optional

[ miniCA ]
certificate = $root/cacert.pem
database = $root/index.txt
private_key = $root/cacert-key.pem
new_certs_dir = $root
default_md = sha1
policy = policy_match
serial = $root/serial
default_days = 10

EOF

    openssl req -x509 -passin pass:$password -passout pass:$password -batch -newkey rsa:2048 -out $root/cacert.pem -keyout $root/cacert-key.pem -subj "/C=FR/O=ACME/CN=$site/OU=ACME-OU"
}

function gen_cert() {
    local name=$2
    local caname=$1
    local caroot=./custom-ca/$caname
    local site="$name.$caname.com"
    echo "gen_cert $caname $name $site  ..."
    openssl req -passin pass:$password -passout pass:$password -batch -newkey rsa:2048 -out $caroot/$name-csr.pem -keyout $caroot/$name-key.pem -subj "/C=FR/O=ACME/CN=$site/OU=ACME-OU"
    openssl ca -config $caroot/ca.cnf -passin pass:$password -batch -notext -in $caroot/$name-csr.pem -out $caroot/$name.pem
}

gen_ca governance
gen_cert governance uicert
gen_ca business

echo "Creating configs..."

cp ./custom-ca/governance/cacert.pem ./files/flowmanager/config/governanceca.pem
cp ./custom-ca/business/cacert.pem ./files/flowmanager/config/businessca.pem
cp ./custom-ca/governance/uicert.pem ./files/flowmanager/config/uicert.pem

ls -l ./files/flowmanager/config/


if [ ! -f ./files/flowmanager/license/license.xml ]; then
    echo "WARNING: ./mounts/config/license.xml is missing"
else
   echo "Success"
fi

