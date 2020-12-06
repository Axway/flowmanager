#!/bin/bash

if [ -z "$1" ]
  then
    echo "No namespace provided."
    exit 1;
fi

if kubectl get namespace $1 | grep -q 'Active'
  then
    echo "The namespace $1 exists"
else 
    echo "The namespace $1 was not found, it will be created"
    kubectl create namespace $1
	echo "Namespace created"
fi

./generate_certs.sh

if [ -f license.xml ]; then
    kubectl create secret generic flowmanager-license --from-file=license.xml -n $1
else
    echo "License was not found in this directory."
fi

if [ -f uicert.p12 ]; then
    kubectl create secret generic flowmanager-uicert --from-file=uicert.p12 -n $1
else
    echo "uicert.p12 was not found in this directory."
fi

if [ -f governanceca.p12 ]; then
    kubectl create secret generic flowmanager-governance --from-file=governanceca.p12 -n $1
else
    echo "governanceca.p12 was not found in this directory."
fi

if [ -f businessca.p12 ]; then
    kubectl create secret generic flowmanager-business --from-file=businessca.p12 -n $1
else
    echo "businessca.p12 was not found in this directory.(not mandatory)"
fi

if [ -f catalog-public-key.pem ]; then
    kubectl create secret generic apicpubkey --from-file=governanceca.p12 -n $1
else
    echo "catalog-public-key.pem was not found in this directory.(not mandatory)"
fi

if [ -f catalog-private-key.pem ]; then
    kubectl create secret generic apicprivkey  --from-file=catalog-private-key.pem -n $1
else
    echo "catalog-private-key.pem was not found in this directory.(not mandatory)"
fi
