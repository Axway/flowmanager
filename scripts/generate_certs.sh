#!/bin/bash
set -euo pipefail

##
# Generate certificates script:
#   - PEM extension certificates
#   - P12 extension certificates
#   - Keystore in JKS
##

CURRENT_DIR=$PWD

# Load config
. $CURRENT_DIR/certs.conf

# Generate CA
function gen_ca() {
    local name=$1
    local root=./custom-ca/$name
    local site="$name.com"
    echo "gen_ca name $site ..."

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
default_days = $EXPIRATION_DAYS

EOF

    openssl req -x509 -days $EXPIRATION_DAYS -passin pass:$PASSWORD -passout pass:$PASSWORD -batch -newkey rsa:2048 -out $root/cacert.pem -keyout $root/cacert-key.pem -subj "/C=FR/O=ACME/CN=$site/OU=ACME-OU"
}

# Genereate PEM certs
function gen_cert() {
    local name=$2
    local caname=$1
    local caroot=./custom-ca/$caname
    local site="$name.$caname.com"

    echo "gen_cert $caname $name $site ..."
    openssl req -passin pass:$PASSWORD -passout pass:$PASSWORD -batch -newkey rsa:2048 -out $caroot/$name-csr.pem -keyout $caroot/$name-key.pem -subj "/C=FR/O=ACME/CN=$site/OU=ACME-OU"
    openssl ca -config $caroot/ca.cnf -passin pass:$PASSWORD -batch -notext -in $caroot/$name-csr.pem -out $caroot/$name.pem
}

# Generate P12 certs
function p12() {
    local path=$1
    local alias=$2

    echo "p12 $1 ..."
    openssl pkcs12 -export -out $path.p12 -name $alias -in $path.pem -inkey $path-key.pem -passin pass:$PASSWORD -passout pass:$PASSWORD
}

# Create Keystore
function jks() {
    local path=$1
    local alias=$2
    echo "jks $1 ..."
    keytool -importkeystore -srckeystore $path.p12 -srcstoretype pkcs12 -srcstorepass $PASSWORD -srcalias $alias -destkeystore $path.jks -deststoretype jks -deststorepass $PASSWORD -destalias $alias
}

# Create PEM certs
function pem() {
    local cert=$1
    local key=$2
    local pemCert=$3

    cat $key.pem > $pemCert.pem
    cat $cert.pem >> $pemCert.pem
}

# Start to generate PEM certs
gen_ca governance
gen_cert governance uicert
gen_ca business

# Start to generate P12 certs
p12 ./custom-ca/governance/cacert governance
p12 ./custom-ca/governance/uicert ui
p12 ./custom-ca/business/cacert business
