#!/bin/bash

err_report() {
    error_message "Error on line" "$1"
}

trap 'err_report" "$LINENO' ERR SIGINT

set -euo pipefail

# Manage user settings
export NAMESPACE="flowmanager"
DOCKER_SERVER="REPLACE"
DOCKER_USERNAME="REPLACE"
DOCKER_PASSWORD="REPLACE"

# Manage parameters
ARG_SOURCE_FOLDER="$1"
ARG_TARGET_FOLDER="$2"
ARG_USER_INPUT_FOLDER="$3"

#Manage temporary variables
MANIFEST_PATH="${ARG_TARGET_FOLDER}/manifests" 


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
# Encode files to base64
# ###################################
base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-core/files/license.xml" > "${ARG_TARGET_FOLDER}/flowmanager-core/files/license.xml.base64"
base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-core/files/fm-governance-ca-full-chain.pem" > "${ARG_TARGET_FOLDER}/flowmanager-core/files/fm-governance-ca-full-chain.pem.base64"
base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-core/files/fm-governance-ca.p12" > "${ARG_TARGET_FOLDER}/flowmanager-core/files/fm-governance-ca.p12.base64"
base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-core/files/fm-governance-ca-cert.pem" > "${ARG_TARGET_FOLDER}/flowmanager-core/files/fm-governance-ca-cert.pem.base64"
base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-core/files/fm-core-jwt-private-key.pem" > "${ARG_TARGET_FOLDER}/flowmanager-core/files/fm-core-jwt-private-key.pem.base64"
base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-core/files/fm-cftplugin-jwt-private-key.pem" > "${ARG_TARGET_FOLDER}/flowmanager-core/files/fm-cftplugin-jwt-private-key.pem.base64"

base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/files/st-fm-plugin-jwt-private-key.pem" > "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/files/st-fm-plugin-jwt-private-key.pem.base64"
base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/files/st-fm-plugin-server-ca-full-chain.pem" > "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/files/st-fm-plugin-server-ca-full-chain.pem.base64"
base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/files/st-fm-plugin-server-cert-key.pem" > "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/files/st-fm-plugin-server-cert-key.pem.base64"
base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/files/st-fm-plugin-server-cert.pem" > "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/files/st-fm-plugin-server-cert.pem.base64"
base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/files/st-fm-plugin-server-public-key.pem" > "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/files/st-fm-plugin-server-public-key.pem.base64"

base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-bridge/files/fm-bridge-jwt-public-key.pem" > "${ARG_TARGET_FOLDER}/flowmanager-bridge/files/fm-bridge-jwt-public-key.pem.base64"
base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-bridge/files/fm-bridge-jwt-private-key.pem" > "${ARG_TARGET_FOLDER}/flowmanager-bridge/files/fm-bridge-jwt-private-key.pem.base64"
base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-bridge/files/fm-bridge-cert-chain.pem" > "${ARG_TARGET_FOLDER}/flowmanager-bridge/files/fm-bridge-cert-chain.pem.base64"
base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-bridge/files/fm-bridge-cert-key.pem" > "${ARG_TARGET_FOLDER}/flowmanager-bridge/files/fm-bridge-cert-key.pem.base64"
base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-bridge/files/fm-bridge-jwt-dosa.json" > "${ARG_TARGET_FOLDER}/flowmanager-bridge/files/fm-bridge-jwt-dosa.json.base64"

base64 -w 0 "${ARG_TARGET_FOLDER}/mongodb/files/fm-mongodb-ca-key.pem" > "${ARG_TARGET_FOLDER}/mongodb/files/fm-mongodb-ca-key.pem.base64"
base64 -w 0 "${ARG_TARGET_FOLDER}/mongodb/files/fm-mongodb-ca.pem" > "${ARG_TARGET_FOLDER}/mongodb/files/fm-mongodb-ca.pem.base64"

# 
# Encode var files to base64
# ###################################
# base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-core/vars/fm-general-encryption-key" > "${ARG_TARGET_FOLDER}/flowmanager-core/vars/fm-general-encryption-key.base64"
# base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-core/vars/fm-bridge-jwt-private-key-password" > "${ARG_TARGET_FOLDER}/flowmanager-core/vars/fm-bridge-jwt-private-key-password.base64"

# base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/vars/st-fm-plugin-shared-secret" > "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/vars/st-fm-plugin-shared-secret.base64"

# base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-bridge/vars/fm-bridge-cert-key-password" > "${ARG_TARGET_FOLDER}/flowmanager-bridge/vars/fm-bridge-cert-key-password.base64"
# base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-bridge/vars/fm-bridge-jwt-dosa.json" > "${ARG_TARGET_FOLDER}/flowmanager-bridge/vars/fm-bridge-jwt-private-key-password.base64"

# base64 -w 0 "${ARG_TARGET_FOLDER}/mongodb/vars/fm-bridge-jwt-private-key-password" > "${ARG_TARGET_FOLDER}/mongodb/vars/fm-bridge-jwt-private-key-password.base64"
# base64 -w 0 "${ARG_TARGET_FOLDER}/mongodb/vars/mongodb-fm-user-password" > "${ARG_TARGET_FOLDER}/mongodb/vars/mongodb-fm-user-password.base64"
# base64 -w 0 "${ARG_TARGET_FOLDER}/mongodb/vars/mongodb-replica-set-key" > "${ARG_TARGET_FOLDER}/mongodb/vars/mongodb-replica-set-key.base64"
# base64 -w 0 "${ARG_TARGET_FOLDER}/mongodb/vars/mongodb-root-password" > "${ARG_TARGET_FOLDER}/mongodb/vars/mongodb-root-password.base64"


#
# Copy manifest files
# ###################################
mkdir ${ARG_TARGET_FOLDER}/manifests
cp ../resources/manifest-templates/mongodb-secret-files-template.yaml ${ARG_TARGET_FOLDER}/manifests/mongodb-secret-files.yaml
cp ../resources/manifest-templates/flowmanager-core-security-files-template.yaml ${ARG_TARGET_FOLDER}/manifests/flowmanager-core-security-files.yaml
cp ../resources/manifest-templates/flowmanager-st-plugin-security-files-template.yaml ${ARG_TARGET_FOLDER}/manifests/flowmanager-st-plugin-security-files.yaml
cp ../resources/manifest-templates/flowmanager-bridge-security-files-template.yaml ${ARG_TARGET_FOLDER}/manifests/flowmanager-bridge-security-files.yaml
cp ../resources/manifest-templates/mongodb-secret-files-template.yaml ${ARG_TARGET_FOLDER}/manifests/mongodb-secret-files.yaml
cp ../resources/manifest-templates/flowmanager-core-security-files-template.yaml ${ARG_TARGET_FOLDER}/manifests/flowmanager-core-security-files.yaml
cp ../resources/manifest-templates/flowmanager-st-plugin-security-files-template.yaml ${ARG_TARGET_FOLDER}/manifests/flowmanager-st-plugin-security-files.yaml
cp ../resources/manifest-templates/flowmanager-bridge-security-files-template.yaml ${ARG_TARGET_FOLDER}/manifests/flowmanager-bridge-security-files.yaml
#
# Replace secrets in manifest files
# ###################################

# Files
FM_MONGODB_CA_CERT=$(cat "${ARG_TARGET_FOLDER}/mongodb/files/fm-mongodb-ca.pem.base64")
FM_MONGODB_CA_KEY=$(cat "${ARG_TARGET_FOLDER}/mongodb/files/fm-mongodb-ca-key.pem.base64")

FM_GOVERNANCECA_P12=$(cat "${ARG_TARGET_FOLDER}/flowmanager-core/files/fm-governance-ca.p12.base64")
FM_GOVERNANCECA_PEM=$(cat "${ARG_TARGET_FOLDER}/flowmanager-core/files/fm-governance-ca-cert.pem.base64")
FM_CORE_JWT_PRIVATE_KEY_PEM=$(cat "${ARG_TARGET_FOLDER}/flowmanager-core/files/fm-core-jwt-private-key.pem.base64")
FM_CORE_GOVERNANCE_CA_FULL_CHAIN_PEM=$(cat "${ARG_TARGET_FOLDER}/flowmanager-core/files/fm-governance-ca-full-chain.pem.base64")
FM_CFTPLUGIN_JWT_PRIVATE_KEY_PEM=$(cat "${ARG_TARGET_FOLDER}/flowmanager-core/files/fm-cftplugin-jwt-private-key.pem.base64")

ST_FM_PLUGIN_CA_PEM=$(cat "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/files/st-fm-plugin-server-ca-full-chain.pem.base64")
ST_FM_PLUGIN_PUBLIC_KEY_PEM=$(cat "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/files/st-fm-plugin-server-public-key.pem.base64")
ST_FM_PLUGIN_PRIVATE_KEY=$(cat "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/files/st-fm-plugin-jwt-private-key.pem.base64")
ST_FM_PLUGIN_CA_PEM=$(cat "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/files/st-fm-plugin-server-ca-full-chain.pem.base64")
ST_FM_PLUGIN_CERT_KEY_PEM=$(cat "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/files/st-fm-plugin-server-cert-key.pem.base64")
ST_FM_PLUGIN_CERT_PEM=$(cat "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/files/st-fm-plugin-server-cert.pem.base64")
ST_FM_PLUGIN_SHARED_SECRET=$(cat "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/vars/st-fm-plugin-shared-secret")

FM_BRIDGE_JWT_PUBLIC_KEY_PEM=$(cat "${ARG_TARGET_FOLDER}/flowmanager-bridge/files/fm-bridge-jwt-public-key.pem.base64")
FM_BRIDGE_DOSA_KEY_PEM=$(cat "${ARG_TARGET_FOLDER}/flowmanager-bridge/files/fm-bridge-jwt-private-key.pem.base64")
FM_BRIDGE_DOSA_JSON=$(cat "${ARG_TARGET_FOLDER}/flowmanager-bridge/files/fm-bridge-jwt-dosa.json.base64")
FM_BRIDGE_FM_BRIDGE_CHAIN_PEM=$(cat "${ARG_TARGET_FOLDER}/flowmanager-bridge/files/fm-bridge-cert-chain.pem.base64")
FM_BRIDGE_FM_BRIDGE_KEY_PEM=$(cat "${ARG_TARGET_FOLDER}/flowmanager-bridge/files/fm-bridge-cert-key.pem.base64")

# MongoDB
sed -i "s|mongodb-ca-cert: .*|mongodb-ca-cert: ${FM_MONGODB_CA_CERT}|g" ${MANIFEST_PATH}/mongodb-secret-files.yaml
sed -i "s|mongodb-ca-key: .*|mongodb-ca-key: ${FM_MONGODB_CA_KEY}|g" ${MANIFEST_PATH}/mongodb-secret-files.yaml

# Flow Manager Core
sed -i "s|governanceca-p12: .*|governanceca-p12: ${FM_GOVERNANCECA_P12}|g" ${MANIFEST_PATH}/mongodb-secret-files.yaml
sed -i "s|fm-core-jwt-private-key.pem: .*|fm-core-jwt-private-key.pem: ${FM_CORE_JWT_PRIVATE_KEY_PEM}|g" ${MANIFEST_PATH}/flowmanager-core-security-files.yaml
sed -i "s|governanceca.p12: .*|governanceca.p12: ${FM_GOVERNANCECA_P12}|g" ${MANIFEST_PATH}/flowmanager-core-security-files.yaml
sed -i "s|mongodb-ca.pem: .*|mongodb-ca.pem: ${FM_MONGODB_CA_CERT}|g" ${MANIFEST_PATH}/flowmanager-core-security-files.yaml
sed -i "s|st-fm-plugin-ca.pem: .*|st-fm-plugin-ca.pem: ${ST_FM_PLUGIN_CA_PEM}|g" ${MANIFEST_PATH}/flowmanager-core-security-files.yaml
sed -i "s|st-fm-plugin-public-key.pem: .*|st-fm-plugin-public-key.pem: ${ST_FM_PLUGIN_PUBLIC_KEY_PEM}|g" ${MANIFEST_PATH}/flowmanager-core-security-files.yaml
sed -i "s|fm-bridge-jwt-public-key.pem: .*|fm-bridge-jwt-public-key.pem: ${FM_BRIDGE_JWT_PUBLIC_KEY_PEM}|g" ${MANIFEST_PATH}/flowmanager-core-security-files.yaml
sed -i "s|fm-cftplugin-jwt-private-key.pem: .*|fm-cftplugin-jwt-private-key.pem: ${FM_CFTPLUGIN_JWT_PRIVATE_KEY_PEM}|g" ${MANIFEST_PATH}/flowmanager-core-security-files.yaml

# Flow Manager SecureTransport Plugin
sed -i "s|governanceca.pem: .*|governanceca.pem: ${FM_GOVERNANCECA_PEM}|g" ${MANIFEST_PATH}/flowmanager-st-plugin-security-files.yaml
sed -i "s|mongodb.pem: .*|mongodb.pem: ${FM_MONGODB_CA_CERT}|g" ${MANIFEST_PATH}/flowmanager-st-plugin-security-files.yaml
sed -i "s|private-key: .*|private-key: ${ST_FM_PLUGIN_PRIVATE_KEY}|g" ${MANIFEST_PATH}/flowmanager-st-plugin-security-files.yaml
sed -i "s|st-fm-plugin-ca.pem: .*|st-fm-plugin-ca.pem: ${ST_FM_PLUGIN_CA_PEM}|g" ${MANIFEST_PATH}/flowmanager-st-plugin-security-files.yaml
sed -i "s|st-fm-plugin-cert-key.pem: .*|st-fm-plugin-cert-key.pem: ${ST_FM_PLUGIN_CERT_KEY_PEM}|g" ${MANIFEST_PATH}/flowmanager-st-plugin-security-files.yaml
sed -i "s|st-fm-plugin-cert.pem: .*|st-fm-plugin-cert.pem: ${ST_FM_PLUGIN_CERT_PEM}|g" ${MANIFEST_PATH}/flowmanager-st-plugin-security-files.yaml
sed -i "s|st-fm-plugin-shared-secret: .*|st-fm-plugin-shared-secret: ${ST_FM_PLUGIN_SHARED_SECRET}|g" ${MANIFEST_PATH}/flowmanager-st-plugin-security-files.yaml

# Flow Manager Bridge
sed -i "s|governanceca.p12: .*|governanceca.p12: ${FM_GOVERNANCECA_P12}|g" ${MANIFEST_PATH}/flowmanager-bridge-security-files.yaml
sed -i "s|fm-governance-ca.pem: .*|fm-governance-ca.pem: ${FM_CORE_GOVERNANCE_CA_FULL_CHAIN_PEM}|g" ${MANIFEST_PATH}/flowmanager-bridge-security-files.yaml
sed -i "s|dosa-key.pem: .*|dosa-key.pem: ${FM_BRIDGE_DOSA_KEY_PEM}|g" ${MANIFEST_PATH}/flowmanager-bridge-security-files.yaml
sed -i "s|dosa.json: .*|dosa.json: ${FM_BRIDGE_DOSA_JSON}|g" ${MANIFEST_PATH}/flowmanager-bridge-security-files.yaml
sed -i "s|fm-bridge-chain.pem: .*|fm-bridge-chain.pem: ${FM_BRIDGE_FM_BRIDGE_CHAIN_PEM}|g" ${MANIFEST_PATH}/flowmanager-bridge-security-files.yaml
sed -i "s|fm-bridge-key.pem: .*|fm-bridge-key.pem: ${FM_BRIDGE_FM_BRIDGE_KEY_PEM}|g" ${MANIFEST_PATH}/flowmanager-bridge-security-files.yaml

# Env Vars
# base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-core/vars/fm-general-encryption-key" > "${ARG_TARGET_FOLDER}/flowmanager-core/vars/fm-general-encryption-key.base64"
# base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-core/vars/fm-bridge-jwt-private-key-password" > "${ARG_TARGET_FOLDER}/flowmanager-core/vars/fm-bridge-jwt-private-key-password.base64"

# base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/vars/st-fm-plugin-shared-secret" > "${ARG_TARGET_FOLDER}/flowmanager-st-plugin/vars/st-fm-plugin-shared-secret.base64"

# base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-bridge/vars/fm-bridge-cert-key-password" > "${ARG_TARGET_FOLDER}/flowmanager-bridge/vars/fm-bridge-cert-key-password.base64"
# base64 -w 0 "${ARG_TARGET_FOLDER}/flowmanager-bridge/vars/fm-bridge-jwt-dosa.json" > "${ARG_TARGET_FOLDER}/flowmanager-bridge/vars/fm-bridge-jwt-private-key-password.base64"

# base64 -w 0 "${ARG_TARGET_FOLDER}/mongodb/vars/fm-bridge-jwt-private-key-password" > "${ARG_TARGET_FOLDER}/mongodb/vars/fm-bridge-jwt-private-key-password.base64"
# base64 -w 0 "${ARG_TARGET_FOLDER}/mongodb/vars/mongodb-fm-user-password" > "${ARG_TARGET_FOLDER}/mongodb/vars/mongodb-fm-user-password.base64"
# base64 -w 0 "${ARG_TARGET_FOLDER}/mongodb/vars/mongodb-replica-set-key" > "${ARG_TARGET_FOLDER}/mongodb/vars/mongodb-replica-set-key.base64"
# base64 -w 0 "${ARG_TARGET_FOLDER}/mongodb/vars/mongodb-root-password" > "${ARG_TARGET_FOLDER}/mongodb/vars/mongodb-root-password.base64"

#
# Create the secrets
# ###################################

# MongoDB
MONGODB_FM_USER_PASSWORD=$(cat "${ARG_TARGET_FOLDER}/mongodb/vars/mongodb-fm-user-password")
MONGODB_ST_PLUGIN_USER_PASSWORD=$(cat "${ARG_TARGET_FOLDER}/mongodb/vars/mongodb-fm-st-plugin-user-password")
MONGODB_PASSWORDS=$MONGODB_FM_USER_PASSWORD,$MONGODB_ST_PLUGIN_USER_PASSWORD
MONGODB_REPLICA_SET_KEY=$(cat "${ARG_TARGET_FOLDER}/mongodb/vars/mongodb-replica-set-key")
MONGODB_ROOT_PASSWORD=$(cat "${ARG_TARGET_FOLDER}/mongodb/vars/mongodb-root-password")

oc create secret generic mongodb-secret-env-vars \
    --from-literal=mongodb-metrics-password="" \
    --from-literal=mongodb-passwords=${MONGODB_PASSWORDS} \
    --from-literal=mongodb-replica-set-key=${MONGODB_REPLICA_SET_KEY} \
    --from-literal=mongodb-root-password=${MONGODB_ROOT_PASSWORD} \
    -n ${NAMESPACE}



# Flow Manager Core
FM_GENERAL_ENCRYPTION_KEY=$(cat "${ARG_TARGET_FOLDER}/flowmanager-core/vars/fm-general-encryption-key")
FM_GOVERNANCE_CA_PASSWORD=$(cat "${ARG_TARGET_FOLDER}/flowmanager-core/vars/fm-governance-ca-password")
FM_USER_INITIAL_PASSWORD=$(cat "${ARG_TARGET_FOLDER}/flowmanager-core/vars/fm-user-initial-password")

oc create secret generic flowmanager-core-security-env-vars \
    --from-literal=FM_DATABASE_USER_PASSWORD=${MONGODB_FM_USER_PASSWORD} \
    --from-literal=FM_GENERAL_ENCRYPTION_KEY=${FM_GENERAL_ENCRYPTION_KEY} \
    --from-literal=FM_GOVERNANCE_CA_PASSWORD=${FM_GOVERNANCE_CA_PASSWORD} \
    --from-literal=FM_USER_INITIAL_PASSWORD=${FM_USER_INITIAL_PASSWORD} \
    -n ${NAMESPACE}

# Flow Manager SecureTransport Plugin

oc create secret generic flowmanager-st-plugin-security-env-vars \
    --from-literal=ST_FM_PLUGIN_DATABASE_USER_PASSWORD=${MONGODB_ST_PLUGIN_USER_PASSWORD} \
    -n ${NAMESPACE}

# Flow Manager Bridge
FM_BRIDGE_CERT_KEY_PASSWORD=$(cat "${ARG_TARGET_FOLDER}/flowmanager-bridge/vars/fm-bridge-cert-key-password")
FM_BRIDGE_JWT_PRIVATE_KEY_PASSWORD=$(cat "${ARG_TARGET_FOLDER}/flowmanager-bridge/vars/fm-bridge-jwt-private-key-password")

oc create secret generic flowmanager-bridge-security-env-vars \
    --from-literal=BRIDGE_KEY_PASSWORD=${FM_BRIDGE_CERT_KEY_PASSWORD} \
    --from-literal=JWT_KEY_PASSWORD=${FM_BRIDGE_JWT_PRIVATE_KEY_PASSWORD} \
    -n ${NAMESPACE}

# License
oc create secret generic flowmanager-core-license --from-file=${ARG_USER_INPUT_FOLDER}/license.xml \
    -n ${NAMESPACE}

# Registry
# oc create secret generic registry-credentials \
#     --from-file=.dockerconfigjson=${ARG_USER_INPUT_FOLDER}/dockerconfig.json \
#     --type=kubernetes.io/dockerconfigjson \
#     -n ${NAMESPACE}

oc create secret docker-registry registry-credentials \
    --docker-server=${DOCKER_SERVER} \
    --docker-username=${DOCKER_USERNAME} \
    --docker-password=${DOCKER_PASSWORD} \
    -n ${NAMESPACE}


oc apply -f ${ARG_TARGET_FOLDER}/manifests/mongodb-secret-files.yaml -n ${NAMESPACE}
oc apply -f ${ARG_TARGET_FOLDER}/manifests/flowmanager-core-security-files.yaml -n ${NAMESPACE}
oc apply -f ${ARG_TARGET_FOLDER}/manifests/flowmanager-st-plugin-security-files.yaml -n ${NAMESPACE}
oc apply -f ${ARG_TARGET_FOLDER}/manifests/flowmanager-bridge-security-files.yaml -n ${NAMESPACE}



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