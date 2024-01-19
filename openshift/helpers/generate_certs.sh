#!/bin/bash

err_report() {
    error_message "Error on line $1"
}

trap 'err_report $LINENO' ERR SIGINT

set -euo pipefail

##
# Generate certificates script:
#   - PEM extension certificates
#   - P12 extension certificates
##

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
echo "Please, choose EXPIRATION_DAYS for the certificates: "
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

[policy_match]
commonName = supplied
countryName = optional
stateOrProvinceName = optional

[ miniCA ]
copy_extensions = copy
certificate = $root/cacert.pem
database = $root/index.txt
private_key = $root/cacert-key.pem
new_certs_dir = $root
default_md = sha256
policy = policy_match
serial = $root/serial
default_days = $EXPIRATION_DAYS

[ req ]
distinguished_name = req_distinguished_name
x509_extensions = v3_ca # The extensions to add to the self signed cert
prompt = no

[ v3_ca ]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = critical,CA:true
keyUsage = cRLSign, keyCertSign, nonRepudiation, digitalSignature, keyEncipherment, keyAgreement
#subjectAltName = @alt_names

[alt_names]
DNS.1 =$site

[ req_distinguished_name ]
emailAddress = example@example.com
commonName = $name
countryName = FR
organizationName = ACME

EOF

    openssl req -x509 -days $EXPIRATION_DAYS -passin pass:$PASSWORD -passout pass:$PASSWORD -batch -newkey rsa:2048 -sha256 -extensions v3_ca -out $root/cacert.pem -keyout $root/cacert-key.pem -config $root/ca.cnf
}

function clean_or_create_custom_ca_folder() {
  local folder_name=$1

  if [ -d "./custom-ca/${folder_name}" ]
  then
    rm -rf "./custom-ca/${folder_name}"
  fi
  mkdir "./custom-ca/${folder_name}"
}

function clean_or_create_custom_ca_root_folder() {
  if [ -d "./custom-ca" ]
  then
    rm -rf "./custom-ca"
  fi
  mkdir "./custom-ca"
}

# Genereate PEM certs
function gen_cert() {
    local name=$2
    local caname=$1
    local caroot=./custom-ca/$caname
    local site="${3:-$name.$caname.com}"

    echo "gen_cert $caname $name $site ..."
    openssl req -passin pass:$PASSWORD -passout pass:$PASSWORD -batch -newkey rsa:2048 -sha256 -extensions v3_ca -out $caroot/$name-csr.pem -keyout $caroot/$name-key.pem -subj "/C=FR/O=ACME/CN=$site/OU=ACME-OU" -addext "subjectAltName=DNS:$site"
    openssl ca -config $caroot/ca.cnf -passin pass:$PASSWORD -batch -notext -in $caroot/$name-csr.pem -out $caroot/$name.pem
    cat $caroot/$name.pem $caroot/cacert.pem > $caroot/$name-chain.pem
}

# Generate P12 certs
function p12() {
    local path=$1
    local alias=$2

    echo "p12 $1 ..."
    openssl pkcs12 -export -out $path.p12 -name $alias -in $path.pem -inkey $path-key.pem -passin pass:$PASSWORD -passout pass:$PASSWORD
}

# Create PEM certs
function pem() {
    local cert=$1
    local key=$2
    local pemCert=$3

    cat $key.pem > $pemCert.pem
    cat $cert.pem >> $pemCert.pem
}

function gen_key_pass() {
  local name="$1"
  local folder="$2"
  mkdir -p "$folder"
  echo "$PASSWORD" | openssl genrsa -passout "stdin" -out "$folder/dosa-key.pem" -aes256 2048
  echo "$PASSWORD" | openssl rsa -in "$folder/dosa-key.pem" -passin "stdin" -outform PEM -pubout -out "$folder/dosa-public.pem"
  chmod a+r "$folder/dosa-key.pem"
  cat >"$folder/dosa.json" <<EOF
{
  "name": "$name",
  "clientId": "$name",
  "publicKey": "$(tr -d '\n' < "$folder/dosa-public.pem")"
}
EOF
}

function gen_key() {
  local name="$1"
  local folder="$2"
  mkdir -p "$folder"
  openssl genrsa -out "$folder/dosa-key.pem" 2048
  openssl rsa -in "$folder/dosa-key.pem" -outform PEM -pubout -out "$folder/dosa-public.pem"
  chmod a+r "$folder/dosa-key.pem"
  cat >"$folder/dosa.json" <<EOF
{
  "name": "$name",
  "clientId": "$name",
  "publicKey": "$(tr -d '\n' < "$folder/dosa-public.pem")"
}
EOF
}

echo "$CURRENT_DIR"

#
# Pre generation clean up
# ###################################
clean_or_create_custom_ca_root_folder
clean_or_create_custom_ca_folder governance
clean_or_create_custom_ca_folder business
clean_or_create_custom_ca_folder fm-mongodb
clean_or_create_custom_ca_folder st-fm-plugin
clean_or_create_custom_ca_folder monitoring-fm-plugin
clean_or_create_custom_ca_folder fm-bridge-ca
clean_or_create_custom_ca_folder fm-agent-ca

clean_or_create_custom_ca_folder fm-cftplugin-key
clean_or_create_custom_ca_folder fm-core-key
clean_or_create_custom_ca_folder fm-stplugin-key
clean_or_create_custom_ca_folder fm-monitoring-kye

#
# Saving certificate password .
# ###################################
echo "$PASSWORD" > ./custom-ca/certs_and_keys_password

#
# Generating componenets certificates .
# ###################################

# FM Governance & Business : CA (with extentions) + leaf cert
gen_ca governance
gen_cert governance uicert
gen_ca business

# FM Governance & Business : convert certs to P12
p12 ./custom-ca/governance/cacert governance
p12 ./custom-ca/governance/uicert ui
p12 ./custom-ca/business/cacert business

chmod 755 ./custom-ca/governance/cacert.p12
chmod 755 ./custom-ca/business/cacert.p12

# FM Governance & Business : convert certs to PEM
pem ./custom-ca/governance/cacert ./custom-ca/governance/cacert-key ./custom-ca/governance/governanceca

# FM ST plugin : CA (without extentions) + leaf cert
openssl genrsa -out ./custom-ca/st-fm-plugin/st-fm-plugin-ca-key.pem 2048
openssl req -x509 -new -key ./custom-ca/st-fm-plugin/st-fm-plugin-ca-key.pem -days $EXPIRATION_DAYS -out ./custom-ca/st-fm-plugin/st-fm-plugin-ca.pem -subj '/C=ro/ST=buch/L=buch/O=axway/OU=fm/CN=rootCA/emailAddress=aa@aa.com'
openssl genrsa -out ./custom-ca/st-fm-plugin/st-fm-plugin-cert-key.pem 2048
openssl req -new -key ./custom-ca/st-fm-plugin/st-fm-plugin-cert-key.pem -out ./custom-ca/st-fm-plugin/st-fm-plugin-cert.csr -subj '/C=ro/ST=buch/L=buch/O=axway/OU=fm/CN=client/emailAddress=bb@bb.com'
openssl x509 -req -days $EXPIRATION_DAYS -CA ./custom-ca/st-fm-plugin/st-fm-plugin-ca.pem -CAkey ./custom-ca/st-fm-plugin/st-fm-plugin-ca-key.pem -CAcreateserial -CAserial ./custom-ca/st-fm-plugin/serial -in ./custom-ca/st-fm-plugin/st-fm-plugin-cert.csr -out ./custom-ca/st-fm-plugin/st-fm-plugin-cert.pem

# FM monitoring plugin : CA (without extentions) + leaf cert
openssl genrsa -out ./custom-ca/monitoring-fm-plugin/monitoring-plugin-ca-key.pem 2048
openssl req -x509 -new -key ./custom-ca/monitoring-fm-plugin/monitoring-plugin-ca-key.pem -days $EXPIRATION_DAYS -out ./custom-ca/monitoring-fm-plugin/monitoring-plugin-ca.pem -subj '/C=ro/ST=buch/L=buch/O=axway/OU=fm/CN=rootCA/emailAddress=aa@aa.com'
openssl genrsa -out ./custom-ca/monitoring-fm-plugin/monitoring-plugin-cert-key.pem 2048
openssl req -new -key ./custom-ca/monitoring-fm-plugin/monitoring-plugin-cert-key.pem -out ./custom-ca/monitoring-fm-plugin/monitoring-plugin-cert.csr -subj '/C=ro/ST=buch/L=buch/O=axway/OU=fm/CN=client/emailAddress=bb@bb.com'
openssl x509 -req -days $EXPIRATION_DAYS -CA ./custom-ca/monitoring-fm-plugin/monitoring-plugin-ca.pem -CAkey ./custom-ca/monitoring-fm-plugin/monitoring-plugin-ca-key.pem -CAcreateserial -CAserial ./custom-ca/monitoring-fm-plugin/serial -in ./custom-ca/monitoring-fm-plugin/monitoring-plugin-cert.csr -out ./custom-ca/monitoring-fm-plugin/monitoring-plugin-cert.pem

# FM Mongodb SSL certificate : CA (without extentions)
openssl genrsa -out ./custom-ca/fm-mongodb/fm-mongodb-ca-key.pem 2048
openssl req -x509 -new -key ./custom-ca/fm-mongodb/fm-mongodb-ca-key.pem -days $EXPIRATION_DAYS -out ./custom-ca/fm-mongodb/fm-mongodb-ca.pem -subj '/C=ro/ST=buch/L=buch/O=axway/OU=fm/CN=fmMongoDbCA/emailAddress=aa@aa.com'

# FM bridge CA (with extentions) & certs
gen_ca fm-bridge-ca
gen_cert fm-bridge-ca fm-bridge fm-bridge

#
# Generating JWT SSH keys & dosa.
# ###################################

# FM bridge (with Password)
gen_key_pass bridge ./custom-ca/fm-bridge-ca

# FM agent (with Password)
gen_key_pass agent ./custom-ca/fm-agent-ca

# FM CFT plugin
gen_key cftplugin ./custom-ca/fm-cftplugin-key
mv ./custom-ca/fm-cftplugin-key/dosa-key.pem ./custom-ca/governance/dosa-cftplugin-key.pem
mv ./custom-ca/fm-cftplugin-key/dosa-public.pem ./custom-ca/governance/dosa-cftplugin-public.pem

# FM Core
gen_key core ./custom-ca/fm-core-key
mv ./custom-ca/fm-core-key/dosa-key.pem ./custom-ca/governance/dosa-core-key.pem
mv ./custom-ca/fm-core-key/dosa-public.pem ./custom-ca/governance/dosa-core-public.pem

# FM ST plugin
gen_key stplugin ./custom-ca/fm-stplugin-key
mv ./custom-ca/fm-stplugin-key/dosa-key.pem ./custom-ca/st-fm-plugin/private-key
mv ./custom-ca/fm-stplugin-key/dosa-public.pem ./custom-ca/st-fm-plugin/public-key

# FM Monitoring plugin
gen_key stplugin ./custom-ca/fm-monitoring-key
mv ./custom-ca/fm-monitoring-key/dosa-key.pem ./custom-ca/monitoring-fm-plugin/private-key
mv ./custom-ca/fm-monitoring-key/dosa-public.pem ./custom-ca/monitoring-fm-plugin/public-key

rm -rf ../resources/openshift-secrets
sh create_openshift_secrets.sh "./custom-ca" "../resources/openshift-secrets" "../resources/input"