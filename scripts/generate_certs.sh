#!/bin/bash
set -euo pipefail

##
# Generate certificates script:
#   - PEM extension certificates
#   - P12 extension certificates
#   - Keystore in JKS
##

HOSTNAME=$(hostname)
FQDN=$(hostname -f)
CURRENT_DIR=$PWD
PASSWORD="abc"
SECOND_PASSWORD="bcd"

# Input Variables
while [ "$PASSWORD" != "$SECOND_PASSWORD" ]
do
    echo "Please, choose a password for the certificates:"
    read -s PASSWORD
    echo "Type the password again:"
    read -s SECOND_PASSWORD

    if [ "$PASSWORD" != "$SECOND_PASSWORD" ]
    then
        echo
        echo "The passwords do not match!"
        echo
    fi
done

echo
echo "Set EXPIRATION_DAYS for the certificates: "
read EXPIRATION_DAYS
echo $EXPIRATION_DAYS

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

[ policy_match ]
commonName = supplied
countryName = optional
stateOrProvinceName = optional

[ miniCA ]
certificate = $root/cacert.pem
database = $root/index.txt
private_key = $root/cacert-key.pem
new_certs_dir = $root
default_md = sha256
policy = policy_match
serial = $root/serial
default_days = $EXPIRATION_DAYS

copy_extensions = copy

[ req ]
distinguished_name = req_distinguished_name
x509_extensions = v3_ca # The extensions to add to the self signed cert
prompt = no

[ v3_ca ]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = critical,CA:true
keyUsage = cRLSign, keyCertSign, nonRepudiation, digitalSignature, keyEncipherment, keyAgreement
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = $HOSTNAME

[ req_distinguished_name ]
emailAddress = example@example.com
commonName = $site
countryName = RO
organizationName = ACME

EOF

    openssl req -x509 -days $EXPIRATION_DAYS -passin pass:$PASSWORD -passout pass:$PASSWORD -batch -newkey rsa:2048 -extensions v3_ca -out $root/cacert.pem -keyout $root/cacert-key.pem -config $root/ca.cnf
}

# Genereate PEM certs
function gen_cert() {
    local name=$2
    local caname=$1
    local caroot=./custom-ca/$caname
    local site="$name.$caname.com"

    echo "gen_cert $caname $name $site ..."
    openssl req -passin pass:$PASSWORD -passout pass:$PASSWORD -batch -newkey rsa:2048 -out $caroot/$name-csr.pem -keyout $caroot/$name-key.pem -subj "/C=RO/O=ACME/CN=$HOSTNAME/OU=ACME-OU" -addext "subjectAltName = DNS:$FQDN"
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

function gen_generic_plugin_certs() {
  local plugin_name=$1

  rm -rf ./custom-ca/"$plugin_name"/
  mkdir -p ./custom-ca/"$plugin_name"

  openssl genrsa -out ./custom-ca/"$plugin_name"/"$plugin_name"-ca-key.pem 2048
  openssl req -x509 -new -key ./custom-ca/"$plugin_name"/"$plugin_name"-ca-key.pem -days $EXPIRATION_DAYS -out ./custom-ca/"$plugin_name"/"$plugin_name"-ca.pem -subj '/C=ro/ST=buch/L=buch/O=axway/OU=fm/CN=rootCA/emailAddress=aa@aa.com'
  openssl genrsa -out ./custom-ca/"$plugin_name"/"$plugin_name"-cert-key.pem 2048
  openssl req -new -key ./custom-ca/"$plugin_name"/"$plugin_name"-cert-key.pem -out ./custom-ca/"$plugin_name"/"$plugin_name"-cert.csr -subj '/C=ro/ST=buch/L=buch/O=axway/OU=fm/CN=client/emailAddress=bb@bb.com'
  openssl x509 -req -days $EXPIRATION_DAYS -CA ./custom-ca/"$plugin_name"/"$plugin_name"-ca.pem -CAkey ./custom-ca/"$plugin_name"/"$plugin_name"-ca-key.pem -CAcreateserial -CAserial ./custom-ca/"$plugin_name"/serial -in ./custom-ca/"$plugin_name"/"$plugin_name"-cert.csr -out ./custom-ca/"$plugin_name"/"$plugin_name"-cert.pem

  ssh-keygen -b 2048 -m pem -f ./custom-ca/"$plugin_name"/key -q -N ""
  openssl rsa -in ./custom-ca/"$plugin_name"/key -pubout -out ./custom-ca/"$plugin_name"/"$plugin_name"-public-key.pem
  mv ./custom-ca/"$plugin_name"/key ./custom-ca/"$plugin_name"/"$plugin_name"-private-key.pem
}

function gen_st_fm_plugin_certs() {
  gen_generic_plugin_certs st-fm-plugin
  openssl rand -base64 500 | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1 > ./custom-ca/st-fm-plugin/st-fm-plugin-shared-secret
}

function gen_monitoring_fm_plugin_certs() {
  gen_generic_plugin_certs monitoring-fm-plugin
}

if [[ -n "${1-}" && "$1" == "monitoring-fm-plugin" ]]; then
  gen_monitoring_fm_plugin_certs
  return
elif [[ -n "${1-}" && "$1" == "st-fm-plugin" ]]; then
  gen_st_fm_plugin_certs
  return
fi

# Start to generate PEM certs
gen_ca governance
gen_cert governance ui
gen_ca business

# generate governance CA and ui cert
pem ./custom-ca/governance/cacert ./custom-ca/governance/cacert-key ./custom-ca/governance/governanceca
pem ./custom-ca/governance/ui ./custom-ca/governance/ui-key ./custom-ca/governance/uicert

# generate business CA
p12 ./custom-ca/business/cacert business

chmod 755 ./custom-ca/governance/governanceca.pem
chmod 755 ./custom-ca/governance/uicert.pem
chmod 755 ./custom-ca/business/cacert.p12

# generate FM CORE JWT key
openssl genrsa -out ./custom-ca/governance/fm-core-jwt-key.pem 2048

# generate ST plugin certs
gen_st_fm_plugin_certs

# generate Monitoring plugin certs
gen_monitoring_fm_plugin_certs

rm -rf ./custom-ca/fm-bridge/
mkdir -p ./custom-ca/fm-bridge/

# generate Bridge certs and keys
echo "unique_subject = no" >> ./custom-ca/governance/index.txt.attr
gen_cert governance bridge
cat ./custom-ca/governance/bridge.pem > ./custom-ca/fm-bridge/fm-bridge-cert.pem
cat ./custom-ca/governance/cacert.pem >> ./custom-ca/fm-bridge/fm-bridge-cert.pem

# generate Bridge Service Account key pair
openssl genrsa -passout pass:$PASSWORD -out  ./custom-ca/fm-bridge/fm-bridge-jwt-private-key.pem 2048
openssl rsa -in ./custom-ca/fm-bridge/fm-bridge-jwt-private-key.pem -outform PEM -pubout -out ./custom-ca/fm-bridge/fm-bridge-jwt-public-key.pem

# generate Bridge Service Account json
name="BRIDGE"
clientId="BRIDGE"
cat >./custom-ca/fm-bridge/fm-bridge-dosa.json <<EOF
{
  "name": "$name",
  "clientId": "$clientId",
  "publicKey": "$(tr -d '\n' < "./custom-ca/fm-bridge/fm-bridge-jwt-public-key.pem")"
}
EOF
