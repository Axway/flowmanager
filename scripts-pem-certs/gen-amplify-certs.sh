#!/bin/bash

if [ ! -f ./docker-compose.yml ]; then
    echo "you should launch this script from root dir as ./scripts/gen-amplify-certs.sh"
    exit 1
fi

echo "Generating AMPLIFY catalog service acccount keys..."

mkdir -p mounts/configs

openssl genpkey -algorithm RSA -out ./mounts/configs/catalog-private-key.pem -pkeyopt rsa_keygen_bits:2048
openssl rsa -pubout -in ./mounts/configs/catalog-private-key.pem -out ./mounts/configs/catalog-public-key.pem

ls -l ./mounts/configs

if [ ! -f ./mounts/configs/license.xml ]; then
    echo "WARNING: ./mounts/config/license.xml is missing"
else
    echo "Success"
fi

