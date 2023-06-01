#!/bin/bash
# set -x
set -euo pipefail

function gen_certs_selfsigned_mon_plugin {
source ./../scripts/generate_certs.sh monitoring-fm-plugin

mkdir -p certs/monitoring-fm-plugin

cp ./custom-ca/governance/governanceca.pem ./certs/governanceca.pem
cp ./custom-ca/monitoring-fm-plugin/monitoring-fm-plugin-ca.pem   ./certs/monitoring-fm-plugin-ca.pem
cp ./custom-ca/monitoring-fm-plugin/monitoring-fm-plugin-cert-key.pem ./certs/monitoring-fm-plugin-cert-key.pem
cp ./custom-ca/monitoring-fm-plugin/monitoring-fm-plugin-cert.pem ./certs/monitoring-fm-plugin-cert.pem
cp ./custom-ca/monitoring-fm-plugin/monitoring-fm-plugin-private-key.pem ./certs/monitoring-fm-plugin-private-key.pem
cp ./custom-ca/monitoring-fm-plugin/monitoring-fm-plugin-public-key.pem ./certs/monitoring-fm-public-key.pem
cp ./custom-ca/monitoring-fm-plugin/monitoring-fm-plugin-shared-secret ./certs/monitoring-fm-plugin-shared-secret

chmod 755 -R ./certs/
rm -rf ./custom-ca/


if [ -f ./certs/monitoring-fm-plugin/monitoring-fm-plugin-ca.pem ]; then
    kubectl create secret generic monitoring-fm-plugin-ca --from-file=./certs/monitoring-fm-plugin/monitoring-fm-plugin-ca.pem -n ${NAMESPACE}
else
    msg_info "monitoring-fm-plugin-ca.pem was not found in ./certs/monitoring-fm-plugin/."
fi

if [ -f ./certs/monitoring-fm-plugin/monitoring-fm-plugin-cert-key.pem ]; then
    kubectl create secret generic monitoring-fm-plugin-cert-key --from-file=./certs/monitoring-fm-plugin/monitoring-fm-plugin-cert-key.pem -n ${NAMESPACE}
else
    msg_info "monitoring-fm-plugin-cert-key.pem was not found in ./certs/monitoring-fm-plugin/."
fi

if [ -f ./certs/monitoring-fm-plugin/monitoring-fm-plugin-cert.pem ]; then
    kubectl create secret generic monitoring-fm-plugin-cert --from-file=./certs/monitoring-fm-plugin/monitoring-fm-plugin-cert.pem -n ${NAMESPACE}
else
    msg_info "monitoring-fm-plugin-cert.pem was not found in ./certs/monitoring-fm-plugin/."
fi

if [ -f ./certs/monitoring-fm-plugin/monitoring-fm-plugin-private-key.pem ]; then
    kubectl create secret generic monitoring-fm-plugin-private-key --from-file=./certs/monitoring-fm-plugin/monitoring-fm-plugin-private-key.pem -n ${NAMESPACE}
else
    msg_info "monitoring-fm-plugin-private-key was not found in ./certs/monitoring-fm-plugin/."
fi

if [ -f ./certs/monitoring-fm-plugin/monitoring-fm-plugin-public-key.pem ]; then
    kubectl create secret generic monitoring-fm-plugin-public-key --from-file=./certs/monitoring-fm-plugin/monitoring-fm-plugin-public-key.pem -n ${NAMESPACE}
else
    msg_info "monitoring-fm-plugin-public-key was not found in ./certs/monitoring-fm-plugin/."
fi

if [ -f ./certs/governanceca.pem ]; then
    kubectl create secret generic governanceca --from-file=./certs/monitoring-fm-plugin/governanceca.pem -n ${NAMESPACE}
else
    msg_info "governanceca was not found in ./certs/."
fi

if [ -f ./certs/monitoring-fm-plugin/monitoring-fm-plugin-shared-secret ]; then
    kubectl create secret generic monitoring-fm-plugin-shared-secret --from-file=./certs/monitoring-fm-plugin/monitoring-fm-plugin-shared-secret -n ${NAMESPACE}
else
    msg_info "monitoring-fm-plugin-shared-secret was not found in ./certs/monitoring-fm-plugin/."
fi

}

function gen_certs_selfsigned_mon_plugin_oc {
source ./../scripts/generate_certs.sh

mkdir -p certs/monitoring-fm-plugin

cp ./custom-ca/governance/governanceca.pem ./certs/governanceca.pem
cp ./custom-ca/monitoring-fm-plugin/monitoring-fm-plugin-ca.pem   ./certs/monitoring-fm-plugin-ca.pem
cp ./custom-ca/monitoring-fm-plugin/monitoring-fm-plugin-cert-key.pem ./certs/monitoring-fm-plugin-cert-key.pem
cp ./custom-ca/monitoring-fm-plugin/monitoring-fm-plugin-cert.pem ./certs/monitoring-fm-plugin-cert.pem
cp ./custom-ca/monitoring-fm-plugin/monitoring-fm-plugin-private-key.pem ./certs/monitoring-fm-plugin-private-key.pem
cp ./custom-ca/monitoring-fm-plugin/monitoring-fm-plugin-public-key.pem ./certs/monitoring-fm-public-key.pem
cp ./custom-ca/monitoring-fm-plugin/monitoring-fm-plugin-shared-secret ./certs/monitoring-fm-plugin-shared-secret

chmod 755 -R ./certs/
rm -rf ./custom-ca/

if [ -f ./certs/monitoring-fm-plugin/monitoring-fm-plugin-ca.pem ]; then
    oc create secret generic monitoring-fm-plugin-ca --from-file=./certs/monitoring-fm-plugin/monitoring-fm-plugin-ca.pem -n ${NAMESPACE}
else
    msg_info "monitoring-fm-plugin-ca.pem was not found in ./certs/monitoring-fm-plugin/."
fi

if [ -f ./certs/monitoring-fm-plugin/monitoring-fm-plugin-cert-key.pem ]; then
    oc create secret generic monitoring-fm-plugin-cert-key --from-file=./certs/monitoring-fm-plugin/monitoring-fm-plugin-cert-key.pem -n ${NAMESPACE}
else
    msg_info "monitoring-fm-plugin-cert-key.pem was not found in ./certs/monitoring-fm-plugin/."
fi

if [ -f ./certs/monitoring-fm-plugin/monitoring-fm-plugin-cert.pem ]; then
    oc create secret generic monitoring-fm-plugin-cert --from-file=./certs/monitoring-fm-plugin/monitoring-fm-plugin-cert.pem -n ${NAMESPACE}
else
    msg_info "monitoring-fm-plugin-cert.pem was not found in ./certs/monitoring-fm-plugin/."
fi

if [ -f ./certs/monitoring-fm-plugin/monitoring-fm-plugin-private-key.pem ]; then
    oc create secret generic monitoring-fm-plugin-private-key --from-file=./certs/monitoring-fm-plugin/monitoring-fm-plugin-private-key.pem -n ${NAMESPACE}
else
    msg_info "monitoring-fm-plugin-private-key was not found in ./certs/monitoring-fm-plugin/."
fi

if [ -f ./certs/monitoring-fm-plugin/monitoring-fm-plugin-public-key.pem ]; then
    oc create secret generic monitoring-fm-plugin-public-key --from-file=./certs/monitoring-fm-plugin/monitoring-fm-plugin-public-key.pem -n ${NAMESPACE}
else
    msg_info "monitoring-fm-plugin-public-key was not found in ./certs/monitoring-fm-plugin/."
fi

if [ -f ./certs/governanceca.pem ]; then
    oc create secret generic governanceca --from-file=./certs/governanceca.pem -n ${NAMESPACE}
else
    msg_info "governanceca was not found in ./certs/."
fi

}