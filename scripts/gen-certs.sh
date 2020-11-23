#!/bin/bash

if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
else
  echo "Please provide .env file."
fi

cd $pathToCerts

set -euo pipefail
err_report() {
    echo "Error on line $1"
}

trap 'err_report $LINENO' ERR


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
default_days = $default_days

EOF

    openssl req -x509 -days $default_days  -passin pass:$password -passout pass:$password -batch -newkey rsa:2048 -out $root/cacert.pem -keyout $root/cacert-key.pem -subj "/C=FR/O=ACME/CN=$site/OU=ACME-OU"
}

function gen_cert() {
    local name=$2
    local caname=$1
    local caroot=./custom-ca/$caname
    local site="$name.$caname.com"
    echo "gen_cert $caname $name $site  ..."
    openssl req -days $default_days -passin pass:$password -passout pass:$password -batch -newkey rsa:2048 -out $caroot/$name-csr.pem -keyout $caroot/$name-key.pem -subj "/C=FR/O=ACME/CN=$site/OU=ACME-OU"
    openssl ca -config $caroot/ca.cnf -passin pass:$password -batch -notext -in $caroot/$name-csr.pem -out $caroot/$name.pem
}

function pem() {
    local path=$1
	local pathKey=$2
    local newpath=$3
	
    cat $2.pem > $3.pem
	cat $1.pem >> $3.pem
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

gen_ca governance
gen_cert governance uicert
gen_ca business

echo "Creating configs..."

p12 ./custom-ca/governance/cacert governance $password
p12 ./custom-ca/governance/uicert ui $password
p12 ./custom-ca/business/cacert business $password


cp ./custom-ca/business/cacert.p12 businessca.p12
cp ./custom-ca/governance/cacert.p12 governanceca.p12
cp ./custom-ca/governance/uicert.p12 uicert.p12

pem ./custom-ca/governance/cacert ./custom-ca/governance/cacert-key  governanceca
pem ./custom-ca/governance/uicert ./custom-ca/governance/uicert-key  uicert
pem ./custom-ca/business/cacert ./custom-ca/business/cacert-key  businessca

rm -rf ./custom-ca/

ls -l ./


if [ ! -f ../license/license.xml ]; then
    echo "WARNING: $pathToLicense/license.xml is missing"
else
   echo "Success"
fi

