#!/bin/bash

err_report() {
    error_message "Error on line" "$1"
}

trap 'err_report" "$LINENO' ERR SIGINT

set -euo pipefail

# Manage parameters
ARG_SOURCE_FOLDER="$1"
ARG_TARGET_FOLDER="$2"
ARG_USER_INPUT_FOLDER="$3"


# TODO Check if source folder exists

#
# Create folder structure for secrets
# ###################################
mkdir "${ARG_TARGET_FOLDER}"
mkdir -p "${ARG_TARGET_FOLDER}/flowmanager-core/files"
mkdir -p "${ARG_TARGET_FOLDER}/flowmanager-core/vars"
mkdir -p "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/files"
mkdir -p "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/vars"
mkdir -p "${ARG_TARGET_FOLDER}/flowmanager-bridge/files"
mkdir -p "${ARG_TARGET_FOLDER}/flowmanager-bridge/vars"
mkdir -p "${ARG_TARGET_FOLDER}/mongodb/files"
mkdir -p "${ARG_TARGET_FOLDER}/mongodb/vars"
mkdir -p "${ARG_TARGET_FOLDER}/others/files"
mkdir -p "${ARG_TARGET_FOLDER}/others/vars"

#
# Copy resources from generated secrets
# ###################################
cp "${ARG_SOURCE_FOLDER}/governance/governanceca.pem" "${ARG_TARGET_FOLDER}/flowmanager-core/files/fm-governance-ca-full-chain.pem"
cp "${ARG_SOURCE_FOLDER}/governance/cacert.p12" "${ARG_TARGET_FOLDER}/flowmanager-core/files/fm-governance-ca.p12"
cp "${ARG_SOURCE_FOLDER}/governance/cacert.pem" "${ARG_TARGET_FOLDER}/flowmanager-core/files/fm-governance-ca-cert.pem"
cp "${ARG_SOURCE_FOLDER}/governance/dosa-core-key.pem" "${ARG_TARGET_FOLDER}/flowmanager-core/files/fm-core-jwt-private-key.pem"
cp "${ARG_SOURCE_FOLDER}/governance/dosa-cftplugin-key.pem" "${ARG_TARGET_FOLDER}/flowmanager-core/files/fm-cftplugin-jwt-private-key.pem"
openssl rand -base64 500 | tr -dc 'a-zA-Z0-9_-' | fold -w 12 | head -n 1 > "${ARG_TARGET_FOLDER}/flowmanager-core/vars/fm-general-encryption-key"
cp "${ARG_SOURCE_FOLDER}/certs_and_keys_password" "${ARG_TARGET_FOLDER}/flowmanager-core/vars/fm-governance-ca-password"
touch "${ARG_TARGET_FOLDER}/flowmanager-core/vars/fm-user-initial-password"

cp "${ARG_SOURCE_FOLDER}/st-fm-plugin/private-key" "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/files/st-fm-plugin-jwt-private-key.pem"
cp "${ARG_SOURCE_FOLDER}/st-fm-plugin/st-fm-plugin-ca.pem" "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/files/st-fm-plugin-server-ca-full-chain.pem"
cp "${ARG_SOURCE_FOLDER}/st-fm-plugin/st-fm-plugin-cert-key.pem" "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/files/st-fm-plugin-server-cert-key.pem"
cp "${ARG_SOURCE_FOLDER}/st-fm-plugin/st-fm-plugin-cert.pem" "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/files/st-fm-plugin-server-cert.pem"
cp "${ARG_SOURCE_FOLDER}/st-fm-plugin/public-key" "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/files/st-fm-plugin-server-public-key.pem"
openssl rand -base64 500 | tr -dc 'a-zA-Z0-9_-' | fold -w 12 | head -n 1 > "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/vars/st-fm-plugin-shared-secret"

cp "${ARG_SOURCE_FOLDER}/fm-bridge-ca/dosa-public.pem" "${ARG_TARGET_FOLDER}/flowmanager-bridge/files/fm-bridge-jwt-public-key.pem"
cp "${ARG_SOURCE_FOLDER}/fm-bridge-ca/dosa-key.pem" "${ARG_TARGET_FOLDER}/flowmanager-bridge/files/fm-bridge-jwt-private-key.pem"
cp "${ARG_SOURCE_FOLDER}/fm-bridge-ca/fm-bridge-chain.pem" "${ARG_TARGET_FOLDER}/flowmanager-bridge/files/fm-bridge-cert-chain.pem"
cp "${ARG_SOURCE_FOLDER}/fm-bridge-ca/fm-bridge-key.pem" "${ARG_TARGET_FOLDER}/flowmanager-bridge/files/fm-bridge-cert-key.pem"
cp "${ARG_SOURCE_FOLDER}/fm-bridge-ca/dosa.json" "${ARG_TARGET_FOLDER}/flowmanager-bridge/files/fm-bridge-jwt-dosa.json"
cp "${ARG_SOURCE_FOLDER}/certs_and_keys_password" "${ARG_TARGET_FOLDER}/flowmanager-bridge/vars/fm-bridge-cert-key-password"
cp "${ARG_SOURCE_FOLDER}/certs_and_keys_password" "${ARG_TARGET_FOLDER}/flowmanager-bridge/vars/fm-bridge-jwt-private-key-password"

cp "${ARG_SOURCE_FOLDER}/fm-mongodb/fm-mongodb-ca-key.pem" "${ARG_TARGET_FOLDER}/mongodb/files/fm-mongodb-ca-key.pem"
cp "${ARG_SOURCE_FOLDER}/fm-mongodb/fm-mongodb-ca.pem" "${ARG_TARGET_FOLDER}/mongodb/files/fm-mongodb-ca.pem"
openssl rand -base64 500 | tr -dc 'a-zA-Z0-9_-' | fold -w 12 | head -n 1 > "${ARG_TARGET_FOLDER}/mongodb/vars/mongodb-fm-user-password"
openssl rand -base64 500 | tr -dc 'a-zA-Z0-9_-' | fold -w 12 | head -n 1 > "${ARG_TARGET_FOLDER}/mongodb/vars/mongodb-fm-st-plugin-user-password"
openssl rand -base64 500 | tr -dc 'a-zA-Z0-9_-' | fold -w 12 | head -n 1 > "${ARG_TARGET_FOLDER}/mongodb/vars/mongodb-root-password"
openssl rand -base64 500 | tr -dc 'a-zA-Z0-9'   | fold -w 16 | head -n 1 > "${ARG_TARGET_FOLDER}/mongodb/vars/mongodb-replica-set-key"

#
# Copy resources from user input
# ###################################
# TODO: Check if folder/file exist and give error if not
cp "${ARG_USER_INPUT_FOLDER}/license.xml" "${ARG_TARGET_FOLDER}/flowmanager-core/files/license.xml"

#
# Generate registry
# ###################################

# function generate_registry_secret  {

#     typeset _artifactory_url
#     typeset _artifactory_username
#     typeset _artifactory_token
#     typeset _artifactory_regcred

#     echo "Artifactory (artifactory.axway.com) Credentials: "
#     echo -n " - Registry URL (Source of images): "
#     read _artifactory_username
#      echo -n " - Username : "
#     read _artifactory_username
#     echo -n " - Identity Token / Password : "
#     read _artifactory_token

#     _artifactory_regcred="$(echo "{\"auths\":{\"${_artifactory_url}\":{\"username\":\"${_artifactory_username}\",\"password\":\"${_artifactory_token}\"}}}" | base64 -w0)"
#     echo $_artifactory_regcred > ${ARG_TARGET_FOLDER}/others/files/registry-credentials
# }

# generate_registry_secret