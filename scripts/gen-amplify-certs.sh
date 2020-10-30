#!/bin/bash


if [ ! -f ./docker-compose.yml ]; then
    cd ../docker-compose
     if [ ! -f ./docker-compose.yml ]; then
          echo "You should launch this script from docker-compose directory!"
          exit 1
     fi 
fi

echo "Generating AMPLIFY catalog service acccount keys..."

openssl genpkey -algorithm RSA -out ./files/flowmanager/config/catalog-private-key.pem -pkeyopt rsa_keygen_bits:2048
openssl rsa -pubout -in ./files/flowmanager/config/catalog-private-key.pem -out ./files/flowmanager/config/catalog-public-key.pem

ls -l ./files/flowmanager/config/

if [ ! -f ./mounts/configs/license.xml ]; then
    echo "WARNING: ./mounts/config/license.xml is missing"
else
    echo "Success"
fi

