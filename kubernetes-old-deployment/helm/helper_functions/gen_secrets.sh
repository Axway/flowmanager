#!/bin/bash
# set -x
set -euo pipefail

function gen_certs_selfsigned {
./../scripts/generate_certs.sh

mkdir -p certs


cp ./custom-ca/governance/governanceca.pem ./certs/governanceca.pem
cp ./custom-ca/governance/uicert.pem ./certs/uicert.pem
cp ./custom-ca/business/cacert.p12  ./certs/businessca.p12
cp ./custom-ca/st-fm-plugin/st-fm-plugin-ca.pem   ./certs/st-fm-plugin-ca.pem
cp ./custom-ca/st-fm-plugin/st-fm-plugin-cert-key.pem ./certs/st-fm-plugin-cert-key.pem
cp ./custom-ca/st-fm-plugin/st-fm-plugin-cert.pem ./certs/st-fm-plugin-cert.pem
cp ./custom-ca/st-fm-plugin/st-fm-plugin-private-key.pem ./certs/st-fm-plugin-private-key.pem
cp ./custom-ca/st-fm-plugin/st-fm-plugin-public-key.pem ./certs/st-fm-plugin-public-key.pem
cp ./custom-ca/st-fm-plugin/st-fm-plugin-shared-secret ./certs/st-fm-plugin-shared-secret
chmod 755 -R ./certs/
rm -rf ./custom-ca/


if [ -f ./license.xml ]; then
    kubectl create secret generic license --from-file=./license.xml -n ${NAMESPACE}
else
    msg_info 'License not found.'
	msg_info 'You can manually run: kubectl create secret generic license --from-file=license.xml -n namespace'
fi

if [ -f ./certs/uicert.pem ]; then
    kubectl create secret generic uicert --from-file=./certs/uicert.pem -n ${NAMESPACE}
else
    msg_info "uicert.p12 was not found in ./certs/."
fi


if [ -f ./certs/st-fm-plugin-ca.pem ]; then
    kubectl create secret generic st-fm-plugin-ca --from-file=./certs/st-fm-plugin-ca.pem -n ${NAMESPACE}
else
    msg_info "st-fm-plugin-ca.pem was not found in ./certs/."
fi

if [ -f ./certs/st-fm-plugin-cert-key.pem ]; then
    kubectl create secret generic st-fm-plugin-cert-key --from-file=./certs/st-fm-plugin-cert-key.pem -n ${NAMESPACE}
else
    msg_info "st-fm-plugin-cert-key.pem was not found in ./certs/."
fi

if [ -f ./certs/st-fm-plugin-cert.pem ]; then
    kubectl create secret generic st-fm-plugin-cert --from-file=./certs/st-fm-plugin-cert.pem -n ${NAMESPACE}
else
    msg_info "st-fm-plugin-cert.pem was not found in ./certs/."
fi

if [ -f ./certs/st-fm-plugin-private-key.pem ]; then
    kubectl create secret generic st-fm-plugin-private-key --from-file=./certs/st-fm-plugin-private-key.pem -n ${NAMESPACE}
else
    msg_info "st-fm-plugin-private-key.pem was not found in ./certs/."
fi

if [ -f ./certs/st-fm-plugin-public-key.pem ]; then
    kubectl create secret generic st-fm-plugic-public-key.pem --from-file=./certs/st-fm-plugin-public-key.pem -n ${NAMESPACE}
else
    msg_info "st-fm-plugin-public-key.pem was not found in ./certs/."
fi

if [ -f ./certs/governanceca.pem ]; then
    kubectl create secret generic governanceca --from-file=./certs/governanceca.pem -n ${NAMESPACE}
else
    msg_info "governanceca.pem was not found in ./certs/."
fi

if [ -f ./certs/st-fm-plugin-shared-secret ]; then
    kubectl create secret generic st-fm-plugin-shared-secret --from-file=./certs/st-fm-plugin-shared-secret -n ${NAMESPACE}
else
    msg_info "st-fm-plugin-shared-secret was not found in ./certs/."
fi

msg_info 'Create docker-registry secret'
echo ""
echo "Please, type your Service Account:"
read -s SERVICE_ACCOUNT
echo "Type the password of your service account:"
read -s SA_PASSWORD
echo ""
kubectl create secret docker-registry regcred --docker-server=docker.repository.axway.com --docker-username=$SERVICE_ACCOUNT --docker-password=$SA_PASSWORD -n ${NAMESPACE}

}

function gen_certs_selfsigned_oc {
./../scripts/generate_certs.sh

mkdir -p certs


cp ./custom-ca/governance/governanceca.pem ./certs/governanceca.pem
cp ./custom-ca/governance/uicert.pem ./certs/uicert.pem
cp ./custom-ca/business/cacert.p12  ./certs/businessca.p12
cp ./custom-ca/st-fm-plugin/st-fm-plugin-ca.pem   ./certs/st-fm-plugin-ca.pem
cp ./custom-ca/st-fm-plugin/st-fm-plugin-cert-key.pem ./certs/st-fm-plugin-cert-key.pem
cp ./custom-ca/st-fm-plugin/st-fm-plugin-cert.pem ./certs/st-fm-plugin-cert.pem
cp ./custom-ca/st-fm-plugin/st-fm-plugin-private-key.pem ./certs/st-fm-plugin-private-key.pem
cp ./custom-ca/st-fm-plugin/st-fm-plugin-public-key.pem ./certs/st-fm-plugin-public-key.pem
cp ./custom-ca/st-fm-plugin/st-fm-plugin-shared-secret ./certs/st-fm-plugin-shared-secret
chmod 755 -R ./certs/
rm -rf ./custom-ca/


if [ -f ./license.xml ]; then
    oc create secret generic license --from-file=./license.xml -n ${NAMESPACE}
else
    msg_info 'License not found.'
	msg_info 'You can manually run: oc create secret generic flowmanager-license --from-file=license.xml -n namespace'
fi

if [ -f ./certs/uicert.pem ]; then
    oc create secret generic uicert --from-file=./certs/uicert.pem -n ${NAMESPACE}
else
    msg_info "uicert.p12 was not found in ./certs/."
fi


if [ -f ./certs/st-fm-plugin-ca.pem ]; then
    oc create secret generic st-fm-plugin-ca --from-file=./certs/st-fm-plugin-ca.pem -n ${NAMESPACE}
else
    msg_info "st-fm-plugin-ca.pem was not found in ./certs/."
fi

if [ -f ./certs/st-fm-plugin-cert-key.pem ]; then
    oc create secret generic st-fm-plugin-cert-key --from-file=./certs/st-fm-plugin-cert-key.pem -n ${NAMESPACE}
else
    msg_info "st-fm-plugin-cert-key.pem was not found in ./certs/."
fi

if [ -f ./certs/st-fm-plugin-cert.pem ]; then
    oc create secret generic st-fm-plugin-cert --from-file=./certs/st-fm-plugin-cert.pem -n ${NAMESPACE}
else
    msg_info "st-fm-plugin-cert.pem was not found in ./certs/."
fi

if [ -f ./certs/st-fm-plugin-private-key.pem ]; then
    oc create secret generic st-fm-plugin-private-key --from-file=./certs/st-fm-plugin-private-key.pem -n ${NAMESPACE}
else
    msg_info "st-fm-plugin-private-key.pem was not found in ./certs/."
fi

if [ -f ./certs/st-fm-plugin-public-key.pem ]; then
    oc create secret generic st-fm-plugin-public-key --from-file=./certs/st-fm-plugin-public-key.pem -n ${NAMESPACE}
else
    msg_info "st-fm-plugin-public-key.pem was not found in ./certs/."
fi

if [ -f ./certs/governanceca.pem ]; then
    oc create secret generic governanceca --from-file=./certs/governanceca.pem -n ${NAMESPACE}
else
    msg_info "governanceca.pem was not found in ./certs/."
fi

if [ -f ./certs/st-fm-plugin-shared-secret ]; then
    oc create secret generic st-fm-plugin-shared-secret --from-file=./certs/st-fm-plugin-shared-secret -n ${NAMESPACE}
else
    msg_info "st-fm-plugin-shared-secret was not found in ./certs/."
fi

msg_info 'Create docker-registry secret'
echo ""
echo "Please, type your Service Account:"
read -s SERVICE_ACCOUNT
echo "Type the password of your service account:"
read -s SA_PASSWORD
echo ""

oc create secret docker-registry regcred --docker-server=docker.repository.axway.com --docker-username=$SERVICE_ACCOUNT --docker-password=$SA_PASSWORD -n ${NAMESPACE}
}
