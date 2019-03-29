#!/bin/bash

if [ ! -f ./docker-compose.yml ]; then
    echo "You should launch this script from root dir as ./scripts/gen-certs.sh"
    exit 1
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

    openssl req -x509 -passin pass:$password -passout pass:$password -batch -newkey rsa:2048 -out $root/cacert.pem -keyout $root/cacert-key.pem -subj "/C=FR/O=ACME/CN=$site/OU=ACME-OU/ST=StateUnknown/L=NoWhere/emailAddress=$email"
}

function gen_cert() {
    local name=$2
    local caname=$1
    local caroot=./custom-ca/$caname
    local site="$name.$caname.com"
    echo "gen_cert $caname $name $site  ..."
    openssl req -passin pass:$password -passout pass:$password -batch -newkey rsa:2048 -out $caroot/$name-csr.pem -keyout $caroot/$name-key.pem -subj "/C=FR/O=ACME/CN=$site/OU=ACME-OU/ST=StateUnknown/L=NoWhere/emailAddress=$email"
    openssl ca -config $caroot/ca.cnf -passin pass:$password -batch -notext -in $caroot/$name-csr.pem -out $caroot/$name.pem
}

function p12() {
    local path=$1
    local alias=$2
    local password=$3
    
    echo "p12 $1 ...."

    openssl pkcs12 -export  -out $path.p12 \
                        -name $alias \
                        -in $path.pem  \
                        -inkey $path-key.pem \
                        -passin pass:$password  \
                        -passout pass:$password
}

function jks() {
    local path=$1
    local alias=$2
    local password=$3
    echo "jks $1 ...."
    keytool -importkeystore \
        -srckeystore $path.p12 -srcstoretype pkcs12 -srcstorepass $password -srcalias $alias \
        -destkeystore $path.jks -deststoretype jks -deststorepass $password -destalias $alias 
}

gen_ca governance
gen_cert governance uicert
gen_ca business

p12 ./custom-ca/governance/cacert governance $password
p12 ./custom-ca/governance/uicert ui $password
p12 ./custom-ca/business/cacert business $password

echo "Creating configs..."
mkdir -p ./mounts/configs
cp ./custom-ca/governance/cacert.p12 ./mounts/configs/governanceca.p12
cp ./custom-ca/business/cacert.p12 ./mounts/configs/businessca.p12
cp ./custom-ca/governance/uicert.p12 ./mounts/configs/uicert.p12

ls -l ./mounts/configs

if [ ! -f ./mounts/configs/license.xml ]; then
    echo "WARNING: ./mounts/config/license.xml is missing"
else
   echo "Success"
fi
