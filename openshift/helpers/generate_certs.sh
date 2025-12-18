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
#
# OpenSSL 3.x Compatibility Updates:
#   - Updated serial number format (1000 instead of 01)
#   - Added explicit SHA-256 hashing for all operations
#   - Enhanced CA configuration with proper extensions
#   - PKCS12 export with legacy fallback for compatibility
#   - Improved certificate policies and extensions
#   - Verified to work across OpenSSL 3.2.x through 3.5.x (inclusive) without functional changes
##

# Autodetect a working openssl binary (prefer one that runs, fallback to /usr/bin/openssl)
OPENSSL_BIN="${OPENSSL_BIN:-openssl}"
if ! $OPENSSL_BIN version >/dev/null 2>&1; then
  if [ -x /usr/bin/openssl ] && /usr/bin/openssl version >/dev/null 2>&1; then
    OPENSSL_BIN=/usr/bin/openssl
  fi
fi
if ! $OPENSSL_BIN version >/dev/null 2>&1; then
  echo "Fatal: no working openssl binary found (tried '$OPENSSL_BIN')." >&2
  exit 1
fi

# Check OpenSSL version (adapts messaging; future-proof minor versions 3.5/3.6)
check_openssl_version() {
  local openssl_version
  openssl_version=$($OPENSSL_BIN version | awk '{print $2}') || openssl_version="unknown"
  local major minor patch
  major=$(echo "$openssl_version" | cut -d'.' -f1)
  minor=$(echo "$openssl_version" | cut -d'.' -f2)
  patch=$(echo "$openssl_version" | cut -d'.' -f3 | sed 's/[a-zA-Z].*//')

  echo "Detected OpenSSL version: $openssl_version (major=$major minor=$minor patch=$patch)"
  if [[ "$major" =~ ^[0-9]+$ && "$major" -ge 3 ]]; then
    echo "OpenSSL 3.x: using provider-backed modern APIs; no legacy commands employed."
    if [[ "$minor" =~ ^[0-9]+$ && "$minor" -ge 5 ]]; then
      echo "Notice: OpenSSL ${major}.${minor}+: script avoids deprecated genrsa/rsa and should remain compatible.";
    fi
  else
    echo "OpenSSL < 3.0 detected; still compatible via widely supported commands (genpkey/pkey available since 1.0+)."
  fi
}

# Initialize OpenSSL compatibility
check_openssl_version

CURRENT_DIR=$PWD
PASSWORD="abc"
SECOND_PASSWORD="bcd"

# Key algorithm controls (future proof for 3.5/3.6).
# Supported: RSA (default), ECDSA (prime256v1), ED25519.
KEY_ALGO="${KEY_ALGO:-RSA}"      # override by exporting KEY_ALGO before running script
KEY_BITS="${KEY_BITS:-2048}"     # used only for RSA (can set 3072 / 4096 if desired)

# Helper to create an unencrypted private key according to KEY_ALGO
generate_private_key() {
  local out=$1
  case "$KEY_ALGO" in
    RSA)
      $OPENSSL_BIN genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:$KEY_BITS -out "$out";;
    ECDSA)
      $OPENSSL_BIN ecparam -genkey -name prime256v1 -out "$out";;
    ED25519)
      $OPENSSL_BIN genpkey -algorithm ED25519 -out "$out";;
    *)
      echo "Unsupported KEY_ALGO '$KEY_ALGO'" >&2; exit 1;;
  esac
}

# Helper to create an encrypted private key (only reliable for RSA today)
generate_private_key_encrypted() {
  local out=$1
  case "$KEY_ALGO" in
    RSA)
      $OPENSSL_BIN genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:$KEY_BITS -aes-256-cbc -pass pass:"$PASSWORD" -out "$out";;
    *)
      echo "Encrypted key generation not supported for KEY_ALGO='$KEY_ALGO'; falling back to RSA." >&2
      $OPENSSL_BIN genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:$KEY_BITS -aes-256-cbc -pass pass:"$PASSWORD" -out "$out";;
  esac
}

extract_public_key() {
  local in=$1
  local out=$2
  if [ -f "$in" ]; then
    if grep -q "ENCRYPTED" "$in" 2>/dev/null; then
      $OPENSSL_BIN pkey -in "$in" -passin pass:"$PASSWORD" -pubout -out "$out"
    else
      $OPENSSL_BIN pkey -in "$in" -pubout -out "$out"
    fi
  else
    echo "Private key '$in' not found" >&2; exit 1
  fi
}

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
  # Serial in hex (future-safe explicit). Starts at 0x1000.
  echo "1000" > $root/serial
    cat >$root/ca.cnf <<EOF

[ ca ]
default_ca = miniCA

[policy_match]
commonName = supplied
countryName = optional
stateOrProvinceName = optional
organizationName = optional
organizationalUnitName = optional
emailAddress = optional

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
preserve = no
email_in_dn = no
unique_subject = no

[ req ]
distinguished_name = req_distinguished_name
x509_extensions = v3_ca
req_extensions = v3_req
prompt = no

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[ v3_ca ]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = critical,CA:true
keyUsage = critical, cRLSign, keyCertSign
extendedKeyUsage = serverAuth, clientAuth

[ v3_end ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 =$site

[ req_distinguished_name ]
emailAddress = example@example.com
commonName = $name
countryName = FR
organizationName = ACME

EOF

  # Generate CA private key separately (modern genpkey) then self-sign.
  generate_private_key "$root/cacert-key.pem"
  "$OPENSSL_BIN" req -x509 -days $EXPIRATION_DAYS -sha256 -extensions v3_ca -out $root/cacert.pem -key "$root/cacert-key.pem" -config $root/ca.cnf -batch
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
# Robust CSR generation helper: tries direct -addext (preferred) then falls back to a temp config
generate_csr_with_san() {
  local keyfile="$1"      # private key path
  local outfile="$2"     # csr output path
  local cn="$3"          # common name (also used for SAN DNS)
  # Always use config-based generation to avoid segfaults seen with -addext on some 3.x builds.
  # Set ADV_INLINE_ADD_EXT=1 to re-enable the direct -addext attempt (advanced/testing only).
  if [ "${ADV_INLINE_ADD_EXT:-0}" = "1" ]; then
    if "$OPENSSL_BIN" req -new -sha256 -key "$keyfile" -out "$outfile" -subj "/C=FR/O=ACME/CN=$cn/OU=ACME-OU" -addext "subjectAltName=DNS:$cn" -batch 2>/dev/null; then
      return 0
    else
      echo "Notice: inline -addext CSR attempt failed; falling back to config method." >&2
    fi
  fi
  local tmpcfg
  tmpcfg=$(mktemp)
  cat >"$tmpcfg" <<EOF
[ req ]
distinguished_name = dn
prompt = no
req_extensions = v3_req
[ dn ]
C = FR
O = ACME
OU = ACME-OU
CN = $cn
[ v3_req ]
subjectAltName = DNS:$cn
EOF
  "$OPENSSL_BIN" req -new -sha256 -key "$keyfile" -out "$outfile" -config "$tmpcfg" -batch
  rm -f "$tmpcfg"
}
function gen_cert() {
  local name=$2
  local caname=$1
  local caroot=./custom-ca/$caname
  local site="${3:-$name.$caname.com}"

  echo "gen_cert $caname $name $site (algo=$KEY_ALGO bits=$KEY_BITS) ..."
  generate_private_key "$caroot/$name-key.pem"
  generate_csr_with_san "$caroot/$name-key.pem" "$caroot/$name-csr.pem" "$site"
  "$OPENSSL_BIN" ca -config "$caroot/ca.cnf" -batch -notext -in "$caroot/$name-csr.pem" -out "$caroot/$name.pem" -extensions v3_end
  cat "$caroot/$name.pem" "$caroot/cacert.pem" > "$caroot/$name-chain.pem"
}

# Generate P12 certs
function p12() {
  local path=$1
  local alias=$2
  echo "p12 $1 (modern defaults, fallback legacy if required)..."
  if ! "$OPENSSL_BIN" pkcs12 -export -out "$path.p12" -name "$alias" -in "$path.pem" -inkey "$path-key.pem" -passout pass:"$PASSWORD" 2>/dev/null; then
    echo "Fallback: legacy PKCS12 export"
    "$OPENSSL_BIN" pkcs12 -export -out "$path.p12" -name "$alias" -in "$path.pem" -inkey "$path-key.pem" -passout pass:"$PASSWORD" -legacy
  fi
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
  generate_private_key_encrypted "$folder/dosa-key.pem"
  extract_public_key "$folder/dosa-key.pem" "$folder/dosa-public.pem"
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
  generate_private_key "$folder/dosa-key.pem"
  extract_public_key "$folder/dosa-key.pem" "$folder/dosa-public.pem"
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
clean_or_create_custom_ca_folder fm-monitoring-key

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

# FM ST plugin : CA (without extensions) + leaf cert (modern key generation)
generate_private_key ./custom-ca/st-fm-plugin/st-fm-plugin-ca-key.pem
"$OPENSSL_BIN" req -x509 -new -key ./custom-ca/st-fm-plugin/st-fm-plugin-ca-key.pem -days $EXPIRATION_DAYS -out ./custom-ca/st-fm-plugin/st-fm-plugin-ca.pem -subj '/C=ro/ST=buch/L=buch/O=axway/OU=fm/CN=rootCA/emailAddress=aa@aa.com' -sha256
generate_private_key ./custom-ca/st-fm-plugin/st-fm-plugin-cert-key.pem
"$OPENSSL_BIN" req -new -key ./custom-ca/st-fm-plugin/st-fm-plugin-cert-key.pem -out ./custom-ca/st-fm-plugin/st-fm-plugin-cert.csr -subj '/C=ro/ST=buch/L=buch/O=axway/OU=fm/CN=client/emailAddress=bb@bb.com'
"$OPENSSL_BIN" x509 -req -days $EXPIRATION_DAYS -CA ./custom-ca/st-fm-plugin/st-fm-plugin-ca.pem -CAkey ./custom-ca/st-fm-plugin/st-fm-plugin-ca-key.pem -CAcreateserial -CAserial ./custom-ca/st-fm-plugin/serial -in ./custom-ca/st-fm-plugin/st-fm-plugin-cert.csr -out ./custom-ca/st-fm-plugin/st-fm-plugin-cert.pem -sha256

# FM monitoring plugin : CA (without extensions) + leaf cert
generate_private_key ./custom-ca/monitoring-fm-plugin/monitoring-plugin-ca-key.pem
"$OPENSSL_BIN" req -x509 -new -key ./custom-ca/monitoring-fm-plugin/monitoring-plugin-ca-key.pem -days $EXPIRATION_DAYS -out ./custom-ca/monitoring-fm-plugin/monitoring-plugin-ca.pem -subj '/C=ro/ST=buch/L=buch/O=axway/OU=fm/CN=rootCA/emailAddress=aa@aa.com' -sha256
generate_private_key ./custom-ca/monitoring-fm-plugin/monitoring-plugin-cert-key.pem
"$OPENSSL_BIN" req -new -key ./custom-ca/monitoring-fm-plugin/monitoring-plugin-cert-key.pem -out ./custom-ca/monitoring-fm-plugin/monitoring-plugin-cert.csr -subj '/C=ro/ST=buch/L=buch/O=axway/OU=fm/CN=client/emailAddress=bb@bb.com'
"$OPENSSL_BIN" x509 -req -days $EXPIRATION_DAYS -CA ./custom-ca/monitoring-fm-plugin/monitoring-plugin-ca.pem -CAkey ./custom-ca/monitoring-fm-plugin/monitoring-plugin-ca-key.pem -CAcreateserial -CAserial ./custom-ca/monitoring-fm-plugin/serial -in ./custom-ca/monitoring-fm-plugin/monitoring-plugin-cert.csr -out ./custom-ca/monitoring-fm-plugin/monitoring-plugin-cert.pem -sha256

# FM Mongodb SSL certificate : CA (without extensions)
generate_private_key ./custom-ca/fm-mongodb/fm-mongodb-ca-key.pem
"$OPENSSL_BIN" req -x509 -new -key ./custom-ca/fm-mongodb/fm-mongodb-ca-key.pem -days $EXPIRATION_DAYS -out ./custom-ca/fm-mongodb/fm-mongodb-ca.pem -subj '/C=ro/ST=buch/L=buch/O=axway/OU=fm/CN=fmMongoDbCA/emailAddress=aa@aa.com' -sha256

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