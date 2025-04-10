#!/bin/bash

set -euo pipefail

ROOT_DB_USER="root"
ROOT_DB_PASS="root_pass"

echo "Please enter the user name of the root user of the database:"
read -r ROOT_DB_USER
echo "Please enter the password of the root user of the database:"
read -r -s ROOT_DB_PASS

if [ ! -f ../../podman/flowmanager.yml ]; then
    echo "flowmanager.yml not found!"
    exit 1
fi

cd ../../podman/
podman pod rm -f flowmanager_pod
sed -i "s/mongo:6.0/mongo:7.0/g" ./flowmanager.yml
podman play kube ./flowmanager.yml

echo "Waiting for mongo.."
sleep 30

podman exec -it flowmanager_pod-mongodb bash -c "mongosh -u $ROOT_DB_USER -p $ROOT_DB_PASS --eval \"db.adminCommand( {setFeatureCompatibilityVersion: '7.0', confirm: true} )\""

echo "MongoDB was upgraded to 7.0!"
