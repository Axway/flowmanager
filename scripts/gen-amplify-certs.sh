#!/bin/bash


if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
else
  echo "Please provide .env file."
fi

cd $pathToCerts
echo "Generating AMPLIFY catalog service acccount keys..."

openssl genpkey -algorithm RSA -out catalog-private-key.pem -pkeyopt rsa_keygen_bits:2048
openssl rsa -pubout -in catalog-private-key.pem -out catalog-public-key.pem

ls -l ./

if [ ! -f ../license/license.xml ]; then
    echo "WARNING: $pathToLicense/license.xml is missing"
else
   echo "Success"
fi

