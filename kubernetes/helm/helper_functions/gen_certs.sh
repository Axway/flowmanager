#!/bin/bash
# set -x
set -euo pipefail

function gen_certs_selfsigned {
./../../scripts/generate_certs.sh

mkdir -p certs

cp ./custom-ca/governance/cacert.p12 ./certs/governanceca.p12
cp ./custom-ca/governance/uicert.p12 ./certs/uicert.p12
cp ./custom-ca/business/cacert.p12  ./certs/businessca.p12

rm -rf ./custom-ca/

if kubectl get namespace ${NAMESPACE} | grep -q 'Active'
  then
    echo "The namespace ${NAMESPACE} exists"
fi

if [ -f ./certs/license.xml ]; then
    kubectl create secret generic flowmanager-license --from-file=./certs/license.xml -n ${NAMESPACE}
else
    echo "License was not found in ./certs/."
fi

if [ -f ./certs/uicert.p12 ]; then
    kubectl create secret generic flowmanager-uicert --from-file=./certs/uicert.p12 -n ${NAMESPACE}
else
    echo "uicert.p12 was not found in ./certs/."
fi

if [ -f ./certs/governanceca.p12 ]; then
    kubectl create secret generic flowmanager-governance --from-file=./certs/governanceca.p12 -n ${NAMESPACE}
else
    echo "governanceca.p12 was not found in ./certs/."
fi

if [ -f ./certs/businessca.p12 ]; then
    kubectl create secret generic flowmanager-business --from-file=./certs/businessca.p12 -n ${NAMESPACE}
else
    echo "businessca.p12 was not found in ./certs/.(not mandatory)"
fi

if [ -f ./certs/catalog-public-key.pem ]; then
    kubectl create secret generic apicpubkey --from-file=./certs/governanceca.p12 -n ${NAMESPACE}
else
    echo "catalog-public-key.pem was not found in ./certs/.(not mandatory)"
fi

if [ -f ./certs/catalog-private-key.pem ]; then
    kubectl create secret generic apicprivkey  --from-file=./certs/catalog-private-key.pem -n ${NAMESPACE}
else
    echo "catalog-private-key.pem was not found in ./certs/.(not mandatory)"
fi

}