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
PASSWORD="$2"
EXPIRATION_DAYS="$3"
CA_PASSWORD="$4"

# Generate CA
function gen_ca() {
  local name=$1
  local root=./custom-ca/$name
  local site="$name.com"
  echo "gen_ca name $site ..."

  touch "$root/index.txt"
  echo -n "01" >"$root/serial"
  cat >"$root/ca.cnf" <<EOF

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

[ alt_names ]
DNS.1 = $HOSTNAME

[ req_distinguished_name ]
emailAddress = example@example.com
commonName = $site
countryName = RO
organizationName = ACME

EOF

  openssl req -x509 -days "$EXPIRATION_DAYS" -passin "pass:$PASSWORD" -passout "pass:$PASSWORD" -batch -newkey rsa:2048 -extensions v3_ca -out "$root/cacert.pem" -keyout "$root/cacert-key.pem" -config "$root/ca.cnf"
}

# Generate PEM certs
function gen_cert() {
  local name=$2
  local caname=$1
  local caroot=./custom-ca/$caname
  local site="$name.$caname.com"

  echo "gen_cert $caname $name $site ..."

  openssl req -passin "pass:$PASSWORD" -passout "pass:$PASSWORD" -batch -newkey rsa:2048 -out "$caroot/$name-csr.pem" -keyout "$caroot/$name-key.pem" -subj "/C=RO/O=ACME/CN=$HOSTNAME/OU=ACME-OU" -addext "subjectKeyIdentifier=hash" -addext "basicConstraints=critical,CA:false" -addext "keyUsage=nonRepudiation,digitalSignature,keyEncipherment,keyAgreement" -addext "extendedKeyUsage=serverAuth,clientAuth" -addext "subjectAltName=DNS:$FQDN"

  openssl ca -config "$caroot/ca.cnf" -passin "pass:$CA_PASSWORD" -batch -notext -in "$caroot/$name-csr.pem" -out "$caroot/$name.pem"
}

# Generate P12 certs
function p12() {
  local path=$1
  local alias=$2

  echo "p12 $1 ..."
  openssl pkcs12 -export -out "$path.p12" -name "$alias" -in "$path.pem" -inkey "$path-key.pem" -passin "pass:$PASSWORD" -passout "pass:$PASSWORD"
}

# Create PEM ca
function pem_ca() {
  local cert=$1
  local key=$2
  local pemCert=$3

  cat "$key.pem" >"$pemCert.pem"
  cat "$cert.pem" >>"$pemCert.pem"
}

function create_or_remove_cert_directory() {
  local name=$1
  rm -rf "./custom-ca/$name"
  mkdir -p "./custom-ca/$name"
}

function gen_plugin_certs() {
  local PLUGIN_NAME=$1
  create_or_remove_cert_directory "$PLUGIN_NAME"
  gen_ca "$PLUGIN_NAME"
  gen_cert "$PLUGIN_NAME" "$PLUGIN_NAME-cert" "$PASSWORD"
  cp "./custom-ca/$PLUGIN_NAME/cacert.pem" "./custom-ca/$PLUGIN_NAME/$PLUGIN_NAME-ca.pem"
}

function gen_keys() {
  local PLUGIN_NAME=$1
  if [ ! -f "./custom-ca/$PLUGIN_NAME-keys" ]; then
    mkdir -p "./custom-ca/$PLUGIN_NAME-keys"
  fi
  openssl genrsa -out "./custom-ca/$PLUGIN_NAME-keys/$PLUGIN_NAME-private-key.pem" 2048
  openssl rsa -in "./custom-ca/$PLUGIN_NAME-keys/$PLUGIN_NAME-private-key.pem" -outform PEM -pubout -out "./custom-ca/$PLUGIN_NAME-keys/$PLUGIN_NAME-public-key.pem"
}

function gen_shared_secret() {
  local PLUGIN_NAME=$1
  openssl rand -base64 500 | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1 >"./custom-ca/$PLUGIN_NAME-keys/$PLUGIN_NAME-shared-secret"
}

function gen_govca() {
  create_or_remove_cert_directory governance
  gen_ca governance
  pem_ca ./custom-ca/governance/cacert ./custom-ca/governance/cacert-key ./custom-ca/governance/governanceca
}

function gen_businessca() {
  create_or_remove_cert_directory business
  gen_ca business
  p12 ./custom-ca/business/cacert business
  mv ./custom-ca/business/cacert.p12 ./custom-ca/business/businessca.p12
}

function gen_certs_fm_bridge() {
  create_or_remove_cert_directory fm-bridge
  echo "unique_subject = no" >>./custom-ca/governance/index.txt.attr
  gen_cert governance bridge
  cat ./custom-ca/governance/bridge.pem >./custom-ca/fm-bridge/fm-bridge-cert.pem
  cat ./custom-ca/governance/cacert.pem >>./custom-ca/fm-bridge/fm-bridge-cert.pem
  cp ./custom-ca/governance/bridge-key.pem ./custom-ca/fm-bridge/fm-bridge-cert-key.pem
}

function gen_keys_fm_bridge() {
  gen_keys fm-bridge
  mv ./custom-ca/fm-bridge-keys/fm-bridge-private-key.pem ./custom-ca/fm-bridge-keys/fm-bridge-jwt-private-key.pem
  mv ./custom-ca/fm-bridge-keys/fm-bridge-public-key.pem ./custom-ca/fm-bridge-keys/fm-bridge-jwt-public-key.pem
  # generate Bridge Service Account json
  name="BRIDGE"
  clientId="BRIDGE"
  cat >./custom-ca/fm-bridge-keys/fm-bridge-dosa.json <<EOF
{
  "name": "$name",
  "clientId": "$clientId",
  "publicKey": "$(tr -d '\n' <"./custom-ca/fm-bridge-keys/fm-bridge-jwt-public-key.pem")"
}
EOF
}

case "${1-}" in
--generate-governance-ca)
  gen_govca
  ;;
--generate-business-ca)
  gen_businessca
  ;;
--generate-st-fm-plugin-certs)
  gen_plugin_certs st-fm-plugin
  ;;
--generate-st-fm-plugin-keys)
  gen_keys st-fm-plugin
  gen_shared_secret st-fm-plugin
  ;;
--generate-monitoring-fm-plugin-certs)
  gen_plugin_certs monitoring-fm-plugin
  ;;
--generate-monitoring-fm-plugin-keys)
  gen_keys monitoring-fm-plugin
  gen_shared_secret monitoring-fm-plugin
  ;;
--generate-fm-bridge-certs)
  gen_certs_fm_bridge
  ;;
--generate-fm-bridge-keys)
  gen_keys_fm_bridge
  ;;
--generate-fm-core-keys)
  gen_keys fm-core
  mv ./custom-ca/fm-core-keys/fm-core-private-key.pem ./custom-ca/fm-core-keys/fm-core-jwt-key.pem
  ;;
*)
  echo "Invalid option: ${1-}"
  ;;
esac
